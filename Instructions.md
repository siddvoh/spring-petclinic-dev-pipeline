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
14. Open the production PetClinic app:`http://localhost:8080`
15. In the Jenkins build, open `ZAP Security Report`
16. Then we could edit any file like `forked_code/src/main/resources/templates/welcome.html` to see some visible change
17. Commit and push the change to `main`.
18. Wait for Jenkins to poll SCM and start a new build and finish the build
19. Refresh the production app: `http://localhost:8080` we will see full changes that just went through the pipeline
34. Stop the containers from the project root: `docker compose -f infra/docker-compose.yml down`
35. Stop the VM: `cd infra/vm && vagrant halt`


----- 
Main files we created/touched: 
1. `Jenkinsfile`
2. `Jenkinsfile.monitoring`
3. `groovy/build-test.groovy`
4. `groovy/clone-repo.groovy`
5. `groovy/deploy.groovy`
6. `groovy/install-docker-compose.groovy`
7. `groovy/sonar-analysis.groovy`
8. `groovy/start-monitoring.groovy`
9. `groovy/zap-analysis.groovy`
10. `groovy/zap-monitoring.groovy`
11. `infra/ansible/deploy.yml`
12. `infra/ansible/inventory.ini`
13. `infra/automated_script.ps1`
14. `infra/automated_script.sh`
15. `infra/docker-compose-no-ports.yml`
16. `infra/docker-compose.yml`
17. `infra/grafana/provisioning/dashboards/dashboards.yml`
18. `infra/grafana/provisioning/dashboards/json/jenkins.json`
19. `infra/grafana/provisioning/dashboards/json/spring-petclinic.json`
20. `infra/grafana/provisioning/datasources/prometheus.yml`
21. `infra/install.ps1`
22. `infra/install.sh`
23. `infra/jenkins/Dockerfile`
24. `infra/jenkins/create-job.groovy`
25. `infra/jenkins/plugins.txt`
26. `infra/prometheus/prometheus.yml`
27. `infra/prometheus/targets/petclinic-targets.yml`
28. `infra/sonarqube/Dockerfile`
29. `infra/vm/Vagrantfile`
30. `infra/zap/Dockerfile`
31. `infra/zap/policies/monitor-config.yml`
32. `infra/zap/policies/scan-config.yml`
