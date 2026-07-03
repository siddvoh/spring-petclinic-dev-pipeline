def deploy() {
    sh '''
        ANSIBLE_HOST_KEY_CHECKING=False \
        ansible-playbook \
            -i infra/ansible/inventory.ini \
            infra/ansible/deploy.yml \
            --extra-vars "app_jar_path=${WORKSPACE}/forked_code/target/spring-petclinic-4.0.0-SNAPSHOT.jar"
    '''
}

return deploy()
