#!/bin/bash

# automated script to install the required pre-requisites:
# - dos2unix
# - Git
# - Docker
# - Docker Compose
# - VirtualBox
# - Vagrant

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

export DID_APT_UPDATE=0

maybe_apt_update() {
    if [[ $DID_APT_UPDATE -eq 0 ]]; then
        echo "Running apt-get update..."
        sudo apt-get update
        DID_APT_UPDATE=1
    fi
}

if ! command_exists dos2unix; then
    echo "dos2unix is not installed. Installing dos2unix..."
    maybe_apt_update
    sudo apt-get install -y dos2unix
else
    echo "dos2unix is already installed."
fi

if ! command_exists git; then
    echo "Git is not installed. Installing Git..."
    maybe_apt_update
    sudo apt-get install -y git
else
    echo "Git is already installed."
fi

if ! command_exists docker; then
    echo "Docker is not installed. Installing Docker..."
    maybe_apt_update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed."
fi

if ! command_exists docker-compose; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    maybe_apt_update
    sudo apt-get install -y docker-compose
else
    echo "Docker Compose is already installed."
fi

if ! command_exists vboxmanage; then
    echo "VirtualBox is not installed. Installing VirtualBox..."
    maybe_apt_update
    sudo apt-get install -y virtualbox
else
    echo "VirtualBox is already installed."
fi

if ! command_exists vagrant; then
    echo "Vagrant is not installed. Installing Vagrant..."
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update
    sudo apt-get install -y vagrant
else
    echo "Vagrant is already installed."
fi

echo "All required pre-requisites have been installed."