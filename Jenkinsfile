pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Build and Test') {
            steps {
                script {
                    load 'groovy/build-test.groovy'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    load 'groovy/sonar-analysis.groovy'
                }
            }
        }

        stage('ZAP Analysis') {
            steps {
                script {
                    load 'groovy/zap-analysis.groovy'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    load 'groovy/deploy.groovy'
                }
            }
        }
    }

    post {
        always {
            publishHTML(target: [
                reportDir: 'zap/reports',
                reportFiles: 'index.html',
                reportName: 'ZAP Security Reports',
                keepAll: true,
                allowMissing: true,
                alwaysLinkToLastBuild: true
            ])
            archiveArtifacts artifacts: 'zap/reports/*.html', allowEmptyArchive: true
        }
    }
}
