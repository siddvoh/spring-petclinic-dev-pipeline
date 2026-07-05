# Step-by-Step Instructions for the pipeline

1. First we need to install Git, Docker, VirtualBox, and Vagrant.
2. Start Docker Desktop
3. From the project root, run: `bash infra/automated_script.sh` and wait for script to finish.
4. Open jenkins: `http://localhost:8081`
5. Open jenkins job: `petclinic-pipeline`
6. Open Blue Ocean from jenkins
7. Open SonarQube: `http://localhost:9000`
8. Then you can login with the creds: `admin` (username) and `Petclinic1234!` (password)
9. Open Prometheus:`http://localhost:9090`
10. In Prometheus, open `Status> Target health`.
11. Open Grafana: `http://localhost:3000`
12. Then you can login with the creds: `admin` (username) and `admin` (password)
13. Open the Jenkins dashboard in Grafana
14. Open the Spring PetClinic dashboard in Grafana.
14. Open the production PetClinic app:`http://localhost:8082`
15. In the Jenkins build, open `ZAP Security Report`
16. Then we could edit any file like `forked_code/src/main/resources/templates/welcome.html` to see some visible change
17. Commit and push the change to `main`.
18. Wait for Jenkins to poll SCM and start a new build and finish the build
19. Refresh the production app: `http://localhost:8082` we will see full changes that just went through the pipeline
34. Stop the containers from the project root: `docker compose -f infra/docker-compose.yml down`
35. Stop the VM: `cd infra/vm && vagrant halt`


----- 
Main files we created/touched: 
1. `Jenkinsfile`
2. `groovy/build-test.groovy`
3. `groovy/sonar-analysis.groovy`
4. `groovy/zap-analysis.groovy`
5. `groovy/deploy.groovy`
6. `infra/automated_script.sh`
7. `infra/docker-compose.yml`
8. `infra/jenkins/Dockerfile`
9. `infra/jenkins/create-job.groovy`
10. `infra/jenkins/plugins.txt`
11. `infra/prometheus/prometheus.yml`
12. `infra/grafana/provisioning/`
13. `infra/zap/Dockerfile`
14. `infra/zap/policies/scan-config.yml`
15. `infra/vm/Vagrantfile`
16. `infra/ansible/deploy.yml`
17. `infra/ansible/inventory.ini`
