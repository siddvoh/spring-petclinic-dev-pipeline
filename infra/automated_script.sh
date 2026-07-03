#!/usr/bin/env bash

set -e

INFRA_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIRECTORY="${INFRA_DIRECTORY}/vm"
SSH_DIRECTORY="${INFRA_DIRECTORY}/jenkins/ssh"
SSH_KEY="${SSH_DIRECTORY}/vagrant_private_key"

cd "${VM_DIRECTORY}"
vagrant up

IDENTITY_FILE="$(
  vagrant ssh-config |
    awk '/IdentityFile/ {gsub(/"/, "", $2); print $2; exit}'
)"

mkdir -p "${SSH_DIRECTORY}"
install -m 600 "${IDENTITY_FILE}" "${SSH_KEY}"

cd "${INFRA_DIRECTORY}"
docker compose build jenkins
docker compose up -d jenkins
