#!/usr/bin/env pwsh

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# & "$PSScriptRoot/install.ps1"; if ($LASTEXITCODE -ne 0) { Write-Error "Failed to install prerequisites"; exit 1 }

$InfraDirectory = $PSScriptRoot
$VmDirectory = Join-Path $InfraDirectory 'vm'
$SshDirectory = Join-Path $InfraDirectory 'jenkins/ssh'
$SshKey = Join-Path $SshDirectory 'vagrant_private_key'
$SonarPassword = 'Petclinic1234!'
$env:SONAR_TOKEN = ''

if ([string]::IsNullOrEmpty($env:DOCKER_CONFIG)) {
    $tempBase = if ($env:TMPDIR) { $env:TMPDIR } else { $env:TEMP }
    $env:DOCKER_CONFIG = Join-Path $tempBase 'petclinic-docker-config'
    New-Item -ItemType Directory -Force -Path $env:DOCKER_CONFIG | Out-Null
    $dockerConfigJson = '{"cliPluginsExtraDirs":["/Applications/Docker.app/Contents/Resources/cli-plugins","/usr/local/lib/docker/cli-plugins","/usr/lib/docker/cli-plugins","/usr/libexec/docker/cli-plugins"]}'
    Set-Content -Path (Join-Path $env:DOCKER_CONFIG 'config.json') -Value $dockerConfigJson
}

function Wait-ForUrl {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )
    for ($attempt = 1; $attempt -le 60; $attempt++) {
        try {
            Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 30 | Out-Null
            return $true
        }
        catch {
            Start-Sleep -Seconds 5
        }
    }
    return $false
}

Push-Location $VmDirectory
try {
    # `vagrant reload` applies any Vagrantfile changes (e.g. new network adapters)
    # to an already-running VM and brings it up if it is halted.
    vagrant reload
    if ($LASTEXITCODE -ne 0) { throw "vagrant reload failed" }

    $identityFile = $null
    foreach ($line in (vagrant ssh-config)) {
        if ($line -match 'IdentityFile\s+"?([^"]+)"?') {
            $identityFile = $Matches[1].Trim()
            break
        }
    }
    if ([string]::IsNullOrEmpty($identityFile)) { throw "Could not determine IdentityFile from vagrant ssh-config" }
}
finally {
    Pop-Location
}

New-Item -ItemType Directory -Force -Path $SshDirectory | Out-Null
Copy-Item -Path $identityFile -Destination $SshKey -Force

Push-Location $InfraDirectory
try {
    docker compose up -d sonarqube
    if ($LASTEXITCODE -ne 0) { throw "docker compose up sonarqube failed" }

    $sonarStatus = ''
    for ($attempt = 1; $attempt -le 60; $attempt++) {
        try {
            $sonarStatus = (Invoke-WebRequest -Uri 'http://127.0.0.1:9000/api/system/status' -UseBasicParsing -TimeoutSec 30).Content
        }
        catch {
            $sonarStatus = ''
        }
        if ($sonarStatus -like '*"status":"UP"*') {
            break
        }
        Start-Sleep -Seconds 5
    }
    if ($sonarStatus -notlike '*"status":"UP"*') { throw "SonarQube did not reach status UP" }

    $adminAuth = "admin:$SonarPassword"
    $adminHeaders = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($adminAuth)) }

    $validateOk = $false
    try {
        $validateResponse = (Invoke-WebRequest -Uri 'http://127.0.0.1:9000/api/authentication/validate' -Headers $adminHeaders -UseBasicParsing -TimeoutSec 30).Content
        if ($validateResponse -match '"valid":true') { $validateOk = $true }
    }
    catch {
        $validateOk = $false
    }

    if (-not $validateOk) {
        $defaultAuth = 'admin:admin'
        $defaultHeaders = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($defaultAuth)) }
        Invoke-WebRequest -Uri 'http://127.0.0.1:9000/api/users/change_password' -Method Post -Headers $defaultHeaders -Body @{
            login            = 'admin'
            previousPassword = 'admin'
            password         = $SonarPassword
        } -UseBasicParsing -TimeoutSec 30 | Out-Null
    }

    try {
        Invoke-WebRequest -Uri 'http://127.0.0.1:9000/api/user_tokens/revoke' -Method Post -Headers $adminHeaders -Body @{ name = 'jenkins' } -UseBasicParsing -TimeoutSec 30 | Out-Null
    }
    catch {
        # ignore if the token does not exist
    }

    $sonarResponse = (Invoke-WebRequest -Uri 'http://127.0.0.1:9000/api/user_tokens/generate' -Method Post -Headers $adminHeaders -Body @{ name = 'jenkins' } -UseBasicParsing -TimeoutSec 30).Content
    if ($sonarResponse -match '"token":"([^"]*)"') {
        $env:SONAR_TOKEN = $Matches[1]
    }
    if ([string]::IsNullOrEmpty($env:SONAR_TOKEN)) { throw "Failed to generate SonarQube token" }

    docker compose up -d --build prometheus grafana app
    if ($LASTEXITCODE -ne 0) { throw "docker compose up prometheus grafana app failed" }
    docker compose build jenkins zap
    if ($LASTEXITCODE -ne 0) { throw "docker compose build jenkins zap failed" }
    docker compose up -d jenkins
    if ($LASTEXITCODE -ne 0) { throw "docker compose up jenkins failed" }

    if (-not (Wait-ForUrl 'http://127.0.0.1:8081/job/petclinic-pipeline/api/json')) {
        throw "Jenkins job endpoint did not become available"
    }

    $nextBuildResponse = (Invoke-WebRequest -Uri 'http://127.0.0.1:8081/job/petclinic-pipeline/api/json?tree=nextBuildNumber' -UseBasicParsing -TimeoutSec 30).Content
    $nextBuildNumber = $null
    if ($nextBuildResponse -match '"nextBuildNumber":([0-9]+)') {
        $nextBuildNumber = $Matches[1]
    }
    if ([string]::IsNullOrEmpty($nextBuildNumber)) { throw "Could not determine next build number" }

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $crumbResponse = (Invoke-WebRequest -Uri 'http://127.0.0.1:8081/crumbIssuer/api/json' -WebSession $session -UseBasicParsing -TimeoutSec 30).Content
    $crumb = $null
    if ($crumbResponse -match '"crumb":"([^"]*)"') {
        $crumb = $Matches[1]
    }
    if ([string]::IsNullOrEmpty($crumb)) { throw "Could not obtain Jenkins crumb" }

    Invoke-WebRequest -Uri 'http://127.0.0.1:8081/job/petclinic-pipeline/build?delay=0sec' -Method Post -Headers @{ 'Jenkins-Crumb' = $crumb } -WebSession $session -UseBasicParsing -TimeoutSec 30 | Out-Null

    $buildResult = ''
    for ($attempt = 1; $attempt -le 360; $attempt++) {
        $buildResponse = ''
        try {
            $buildResponse = (Invoke-WebRequest -Uri "http://127.0.0.1:8081/job/petclinic-pipeline/$nextBuildNumber/api/json" -UseBasicParsing -TimeoutSec 30).Content
        }
        catch {
            $buildResponse = ''
        }
        if ($buildResponse -match '"result":"([^"]*)"') {
            $buildResult = $Matches[1]
        }
        if (-not [string]::IsNullOrEmpty($buildResult)) {
            break
        }
        Start-Sleep -Seconds 5
    }

    if ($buildResult -ne 'SUCCESS') { throw "Jenkins build did not succeed (result: $buildResult)" }

    if (-not (Wait-ForUrl 'http://127.0.0.1:8082/')) { throw "App endpoint did not become available" }
    if (-not (Wait-ForUrl 'http://127.0.0.1:9101/metrics')) { throw "Node exporter endpoint did not become available" }
    if (-not (Wait-ForUrl 'http://127.0.0.1:9090/-/ready')) { throw "Prometheus endpoint did not become available" }
    if (-not (Wait-ForUrl 'http://127.0.0.1:3000/api/health')) { throw "Grafana endpoint did not become available" }

    docker exec jenkins test -f /zap/reports/petclinic-zap-report.html
    if ($LASTEXITCODE -ne 0) { throw "ZAP report not found in jenkins container" }
}
finally {
    Pop-Location
}
