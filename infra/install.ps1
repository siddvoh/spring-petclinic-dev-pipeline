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

# Check and install Git
if (-not (Command-Exists "git")) {
    Write-Host "Git is not installed. Installing Git..."
    # Add installation command for Git here
    winget install -e --id Git.Git
} else {
    Write-Host "Git is already installed."
}

# Check and install Docker
if (-not (Command-Exists "docker")) {
    Write-Host "Docker is not installed. Installing Docker..."
    # Add installation command for Docker here
    winget install -e --id Docker.DockerDesktop
} else {
    Write-Host "Docker is already installed."
}

# Check and install VirtualBox
if (-not (Command-Exists "vboxmanage")) {
    Write-Host "VirtualBox is not installed. Installing VirtualBox..."
    # Add installation command for VirtualBox here
    winget install -e --id Oracle.VirtualBox
} else {
    Write-Host "VirtualBox is already installed."
}

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