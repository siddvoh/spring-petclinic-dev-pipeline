def installDockerCompose() {

    stage('Install Docker Compose v2') {
        script {
            COMPOSE_VERSION = '5.2.0'

            def arch = sh(
                script: "uname -m",
                returnStdout: true
            ).trim()

            def composeBinary = ""
            if (arch == "x86_64") {
                composeBinary = "docker-compose-linux-x86_64"
            } else if (arch == "aarch64") {
                composeBinary = "docker-compose-linux-aarch64"
            } else {
                error "Unsupported architecture detected: ${arch}"
            }

            sh """
                curl -SL "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/${composeBinary}" \
                    -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
            """

            echo "Installed Docker Compose v2 for architecture: ${arch}"
            sh 'docker-compose version'
        }
    }

}

return installDockerCompose()
