/*
Runs SonarQube static analysis for the forked spring-petclinic app and
waits for the quality gate result before allowing the pipeline to continue.
*/
def runSonarQubeAnalysis() {
    stage('Run SonarQube Analysis') {
        withSonarQubeEnv('SonarQube') {
            sh '''
                cd forked_code
                ./mvnw -B clean verify sonar:sonar -DskipTests
            '''
        }

        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}

return runSonarQubeAnalysis()