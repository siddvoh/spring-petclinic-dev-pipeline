# Spring PetClinic DevSecOps Pipeline

This repository contains a containerized DevSecOps pipeline for the Spring PetClinic application. It includes Jenkins for CI, SonarQube for static analysis, Prometheus and Grafana for monitoring, ZAP for security analysis, and Ansible + Vagrant for deployment to a production VM.

## Demo Video

- [Project demo video](https://drive.google.com/file/d/1lwCQoeSoeJKiMyQ8W7cxPlWySpwPn9Na/view?usp=sharing)

## Key Documents

- [Step-by-step instructions](Instructions.md)
- [Jenkins pipeline](Jenkinsfile)
- [Monitoring pipeline](Jenkinsfile.monitoring)

## Main Automation

- `infra/automated_script.sh` bootstraps the local environment and runs the full pipeline.
- `infra/docker-compose.yml` defines Jenkins, SonarQube, Prometheus, Grafana, ZAP, and the monitoring sidecars.
- `infra/ansible/deploy.yml` deploys the application to the production VM.

## Evidence

Screenshots and supporting submission artifacts are stored in `screenshots/` and `analysis/`.

## Touched Files

- `Jenkinsfile`
- `Jenkinsfile.monitoring`
- `groovy/build-test.groovy`
- `groovy/clone-repo.groovy`
- `groovy/deploy.groovy`
- `groovy/install-docker-compose.groovy`
- `groovy/sonar-analysis.groovy`
- `groovy/start-monitoring.groovy`
- `groovy/zap-analysis.groovy`
- `groovy/zap-monitoring.groovy`
- `infra/ansible/deploy.yml`
- `infra/ansible/inventory.ini`
- `infra/automated_script.ps1`
- `infra/automated_script.sh`
- `infra/docker-compose-no-ports.yml`
- `infra/docker-compose.yml`
- `infra/grafana/provisioning/dashboards/dashboards.yml`
- `infra/grafana/provisioning/dashboards/json/jenkins.json`
- `infra/grafana/provisioning/dashboards/json/spring-petclinic.json`
- `infra/grafana/provisioning/datasources/prometheus.yml`
- `infra/install.ps1`
- `infra/install.sh`
- `infra/jenkins/Dockerfile`
- `infra/jenkins/create-job.groovy`
- `infra/jenkins/plugins.txt`
- `infra/prometheus/prometheus.yml`
- `infra/prometheus/targets/petclinic-targets.yml`
- `infra/sonarqube/Dockerfile`
- `infra/vm/Vagrantfile`
- `infra/zap/Dockerfile`
- `infra/zap/policies/monitor-config.yml`
- `infra/zap/policies/scan-config.yml`