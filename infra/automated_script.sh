#!/usr/bin/env bash

set -e

#./infra/install.sh || { echo "Failed to install prerequisites"; exit 1; }

INFRA_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIRECTORY="${INFRA_DIRECTORY}/vm"
SSH_DIRECTORY="${INFRA_DIRECTORY}/jenkins/ssh"
SSH_KEY="${SSH_DIRECTORY}/vagrant_private_key"
SONAR_PASSWORD="Petclinic1234!"
export SONAR_TOKEN=""

if [[ -z "${DOCKER_CONFIG:-}" ]]; then
  DOCKER_CONFIG="${TMPDIR:-/tmp}/petclinic-docker-config"
  mkdir -p "${DOCKER_CONFIG}"
  printf '%s\n' '{"cliPluginsExtraDirs":["/Applications/Docker.app/Contents/Resources/cli-plugins","/usr/local/lib/docker/cli-plugins","/usr/lib/docker/cli-plugins","/usr/libexec/docker/cli-plugins"]}' > "${DOCKER_CONFIG}/config.json"
  export DOCKER_CONFIG
fi

wait_for_url() {
  for attempt in {1..60}; do
    if curl -fsS "$1" > /dev/null 2>&1; then
      return 0
    fi
    sleep 5
  done
  return 1
}

cd "${VM_DIRECTORY}"
vagrant up

IDENTITY_FILE="$(
  vagrant ssh-config |
    awk '/IdentityFile/ {gsub(/"/, "", $2); print $2; exit}'
)"

mkdir -p "${SSH_DIRECTORY}"
install -m 600 "${IDENTITY_FILE}" "${SSH_KEY}"

cd "${INFRA_DIRECTORY}"
docker compose up -d sonarqube

for attempt in {1..60}; do
  SONAR_STATUS="$(curl -fsS http://127.0.0.1:9000/api/system/status 2> /dev/null || true)"
  if [[ "${SONAR_STATUS}" == *'"status":"UP"'* ]]; then
    break
  fi
  sleep 5
done
[[ "${SONAR_STATUS}" == *'"status":"UP"'* ]]

if ! curl -fsS -u "admin:${SONAR_PASSWORD}" http://127.0.0.1:9000/api/authentication/validate | grep -q '"valid":true'; then
  curl -fsS -u admin:admin -X POST http://127.0.0.1:9000/api/users/change_password \
    -d login=admin \
    -d previousPassword=admin \
    -d "password=${SONAR_PASSWORD}" > /dev/null
fi

curl -fsS -u "admin:${SONAR_PASSWORD}" -X POST http://127.0.0.1:9000/api/user_tokens/revoke \
  -d name=jenkins > /dev/null 2>&1 || true

SONAR_RESPONSE="$(curl -fsS -u "admin:${SONAR_PASSWORD}" -X POST http://127.0.0.1:9000/api/user_tokens/generate -d name=jenkins)"
SONAR_TOKEN="$(printf '%s' "${SONAR_RESPONSE}" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
test -n "${SONAR_TOKEN}"
export SONAR_TOKEN

docker compose up -d --build prometheus grafana app
docker compose build jenkins zap
docker compose up -d jenkins

wait_for_url http://127.0.0.1:8081/job/petclinic-pipeline/api/json

NEXT_BUILD_NUMBER="$(curl -fsS 'http://127.0.0.1:8081/job/petclinic-pipeline/api/json?tree=nextBuildNumber' | sed -n 's/.*"nextBuildNumber":\([0-9]*\).*/\1/p')"
COOKIE_FILE="$(mktemp)"
CRUMB="$(curl -fsS -c "${COOKIE_FILE}" http://127.0.0.1:8081/crumbIssuer/api/json | sed -n 's/.*"crumb":"\([^"]*\)".*/\1/p')"
test -n "${NEXT_BUILD_NUMBER}"
test -n "${CRUMB}"

curl -fsS -b "${COOKIE_FILE}" -X POST -H "Jenkins-Crumb: ${CRUMB}" "http://127.0.0.1:8081/job/petclinic-pipeline/build?delay=0sec" > /dev/null
rm "${COOKIE_FILE}"

for attempt in {1..360}; do
  BUILD_RESPONSE="$(curl -fsS "http://127.0.0.1:8081/job/petclinic-pipeline/${NEXT_BUILD_NUMBER}/api/json" || true)"
  BUILD_RESULT="$(printf '%s' "${BUILD_RESPONSE}" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p')"
  if [[ -n "${BUILD_RESULT}" ]]; then
    break
  fi
  sleep 5
done

test "${BUILD_RESULT}" = "SUCCESS"
wait_for_url http://127.0.0.1:8082/
wait_for_url http://127.0.0.1:9090/-/ready
wait_for_url http://127.0.0.1:3000/api/health
docker exec jenkins test -f /zap/reports/petclinic-zap-report.html
