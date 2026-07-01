pipeline {
    agent any
    stages {
        stage("Install Docker Compose") {
            steps {
                script {
                    load 'groovy/install-docker-compose.groovy'
                }
            }
        }
        stage("Clone Repo") {
            steps {
                script {
                    load 'groovy/clone-repo.groovy'
                }
            }
        }

        ///////////////////////////////////
        // probably run other modules here?
        ///////////////////////////////////

        stage("Run ZAP Scans") {
            steps {
                script {
                    load 'groovy/zap-analysis.groovy'
                }
            }
        }

        ///////////////////////////////////
        // probably deploy to production here?
        ///////////////////////////////////

        stage("Run ZAP Monitoring") { //maybe by ssh into production VM?
            steps {
                script {
                    load 'groovy/zap-monitoring.groovy'
                }
            }
        }
    }
}
