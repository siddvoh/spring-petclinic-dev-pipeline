# Instructions

## Prerequisites

Install the following:

- Git
- Docker (via Docker Desktop)
- VirtualBox
- Vagrant 

## Step-by-Step Instructions to Run the Pipeline

1. Start Docker Desktop.
2. From the project root, run `bash infra/automated_script.sh` and wait for the script to finish.
3. Open Jenkins at `http://localhost:8081`.
4. Open the `petclinic-pipeline` job.
5. Open Blue Ocean from Jenkins.
6. Open SonarQube at `http://localhost:9000`.
7. Log in with `admin` / `Petclinic1234!`.
8. Open Prometheus at `http://localhost:9090`.
9. In Prometheus, open `Status > Target health`.
10. Open Grafana at `http://localhost:3000`.
11. Log in with `admin` / `admin`.
12. Open the Jenkins dashboard in Grafana.
13. Open the Spring PetClinic dashboard in Grafana.
14. Open the production PetClinic app at `http://localhost:8080`.
15. In the Jenkins build, open `ZAP Security Report`.
16. Edit a file such as `forked_code/src/main/resources/templates/welcome.html` to make a visible change.
17. Commit and push the change to `main`.
18. Wait for Jenkins to poll SCM and finish the new build.
19. Refresh the production app at `http://localhost:8080` to confirm the updated content.
20. Stop the containers from the project root with `docker compose -f infra/docker-compose.yml down`.
21. Stop the VM with `cd infra/vm && vagrant halt`.

## Optional: Reorganize screenshots

If you'd like to tidy the `screenshots/` folder, run the included reorganization script from the project root. First perform a dry run to review the planned moves:

```bash
bash infra/scripts/reorganize_screenshots.sh --dry-run
```

If the dry run looks OK, run the script (this will move and rename files):

```bash
bash infra/scripts/reorganize_screenshots.sh
```

The script will create categorized folders under `screenshots/` (jenkins, grafana, prometheus, sonarqube, zap, app, reports, other) and rename files to `YYYY-MM-DD_<category>_NN.ext`.
