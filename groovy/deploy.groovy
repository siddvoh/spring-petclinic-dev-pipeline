def deploy() {
    sh '''
        # The mounted Docker secret is world-readable (0777 on Windows bind mounts),
        # which OpenSSH rejects. Copy it to a private location with 600 permissions.
        install -m 600 /run/secrets/vagrant_private_key "${WORKSPACE}/.vagrant_private_key"

        SSH_PORT="2222"
        SSH_OPTS="-p ${SSH_PORT} -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -i ${WORKSPACE}/.vagrant_private_key"

        if ! timeout 20 ssh ${SSH_OPTS} vagrant@host.docker.internal 'exit 0' >/dev/null 2>&1; then
            echo "ERROR: Cannot complete SSH handshake to host.docker.internal:${SSH_PORT} from Jenkins container."
            exit 2
        fi

        echo "Using SSH port ${SSH_PORT} for Ansible deploy"

        ANSIBLE_HOST_KEY_CHECKING=False \
        ansible-playbook \
            -i infra/ansible/inventory.ini \
            infra/ansible/deploy.yml \
            --extra-vars "app_jar_path=${WORKSPACE}/forked_code/target/spring-petclinic-4.0.0-SNAPSHOT.jar" \
            --extra-vars "ansible_ssh_private_key_file=${WORKSPACE}/.vagrant_private_key" \
            --extra-vars "ansible_port=${SSH_PORT}"
    '''

}

return deploy()
