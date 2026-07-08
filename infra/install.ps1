# automated script to install the required pre-requisites:
# - Git
# - Docker Desktop
# - VirtualBox
# - Vagrant

# Function to check if a command exists
function Command-Exists {
    param (
        [string]$Command
    )
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Is-PackageInstalledWithWinget {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )

    if (-not (Command-Exists 'winget')) {
        return $false
    }

    $output = (& winget list --id $PackageId -e --accept-source-agreements 2>&1 | Out-String)
    return ($output -notmatch 'No installed package found matching input criteria')
}

function Install-WithWingetIfMissing {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,
        [scriptblock]$IsInstalledCheck
    )

    if (& $IsInstalledCheck) {
        Write-Host "$DisplayName is already installed."
        return
    }

    if (-not (Command-Exists 'winget')) {
        throw "winget is not available, cannot install $DisplayName"
    }

    Write-Host "$DisplayName is not installed. Installing $DisplayName..."
    & winget install -e --id $PackageId --accept-package-agreements --accept-source-agreements

    if (-not (& $IsInstalledCheck)) {
        throw "Failed to install $DisplayName"
    }

    Write-Host "$DisplayName is installed."
}

function Test-VirtualBoxInstalled {
    if (Is-PackageInstalledWithWinget 'Oracle.VirtualBox') {
        return $true
    }

    if (Command-Exists 'VBoxManage.exe') {
        return $true
    }

    if (Command-Exists 'vboxmanage') {
        return $true
    }

    $defaultPath = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
    return (Test-Path $defaultPath)
}

Install-WithWingetIfMissing -PackageId 'Git.Git' -DisplayName 'Git' -IsInstalledCheck { Command-Exists 'git' }

Install-WithWingetIfMissing -PackageId 'Docker.DockerDesktop' -DisplayName 'Docker Desktop' -IsInstalledCheck { Command-Exists 'docker' }

Install-WithWingetIfMissing -PackageId 'Oracle.VirtualBox' -DisplayName 'VirtualBox' -IsInstalledCheck { Test-VirtualBoxInstalled }

# Check and install Vagrant
if (-not (Command-Exists "vagrant")) {
    Write-Host "Vagrant is not installed. Installing Vagrant..."
    # Add installation command for Vagrant here
    # download and install Vagrant from the official website
    $vagrantUrl = "https://releases.hashicorp.com/vagrant/2.4.9/vagrant_2.4.9_windows_amd64.msi"
    $vagrantInstaller = "$env:TEMP\vagrant_2.4.9_windows_amd64.msi"
    Invoke-WebRequest -Uri $vagrantUrl -OutFile $vagrantInstaller
    Start-Process msiexec.exe -ArgumentList "/i `"$vagrantInstaller`" /quiet /norestart" -Wait
} else {
    Write-Host "Vagrant is already installed."
}

exit 0