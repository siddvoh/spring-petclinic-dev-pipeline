def deploy() {
    sh '''
        # The mounted Docker secret is world-readable (0777 on Windows bind mounts),
        # which OpenSSH rejects. Copy it to a private location with 600 permissions.
        install -m 600 /run/secrets/vagrant_private_key "${WORKSPACE}/.vagrant_private_key"

        # Prefer 2223 (portproxy, if configured), then fall back to direct 2222.
        SSH_PORT=""
        for p in 2223 2222; do
            if timeout 10 bash -lc "</dev/tcp/host.docker.internal/${p}" 2>/dev/null; then
                SSH_PORT="${p}"
                break
            fi
        done

        if [ -z "${SSH_PORT}" ]; then
            echo "ERROR: Cannot reach host.docker.internal on SSH ports 2223 or 2222 from Jenkins container."
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

    def prometheusTarget = load 'groovy/prometheus-target.groovy'
    prometheusTarget.setPrometheusTarget('host.docker.internal:8082', 'production')
}

return deploy()
