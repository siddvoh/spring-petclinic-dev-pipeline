def cloneRepo() {
    git branch: 'ZAP', credentialsId: 'joe2',
        url: 'https://github.com/siddvoh/spring-petclinic-dev-pipeline.git'
}

return cloneRepo()
