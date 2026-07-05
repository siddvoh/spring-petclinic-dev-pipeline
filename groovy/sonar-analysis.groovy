def runSonarQubeAnalysis() {
    dir('forked_code') {
        sh './mvnw -B sonar:sonar -Dsonar.host.url=http://sonarqube:9000 -Dsonar.token=$SONAR_TOKEN'
    }
}

return runSonarQubeAnalysis()
