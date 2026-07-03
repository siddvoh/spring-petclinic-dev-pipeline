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

        stage('Deploy') {
            steps {
                script {
                    load 'groovy/deploy.groovy'
                }
            }
        }
    }
}
