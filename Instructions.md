## SonarQube Implementation

1. Start the SonarQube container from `infra/docker-compose.yml` on the shared `miniproject-net` network.
2. In Jenkins, create or verify a SonarQube server entry named `SonarQube` and connect it to a token-based credential.
3. Ensure Jenkins has the SonarQube plugin installed; it is already listed in `infra/jenkins/plugins.txt`.
4. Run the pipeline stage `Run SonarQube Analysis`, which executes `./mvnw -B clean verify sonar:sonar -DskipTests` inside `forked_code`.
5. Wait for the quality gate result in Jenkins. The pipeline aborts if the SonarQube gate fails.
6. View the project in SonarQube after the scan completes to confirm the analysis, issues, and quality gate status.

### Required Jenkins configuration

- SonarQube server name: `SonarQube`
- Jenkins credential: a Sonar token stored as a secret text credential
- Webhook: SonarQube should be configured to notify Jenkins so `waitForQualityGate` can resolve

### Notes

- The SonarQube container uses persistent volumes for data, extensions, and logs.
- The app build already includes Spring Boot Actuator and JaCoCo, so SonarQube can consume standard Maven build output without extra application changes.
