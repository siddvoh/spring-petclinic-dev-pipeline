def deploy() {
    sh '''
        # The mounted Docker secret is world-readable (0777 on Windows bind mounts),
        # which OpenSSH rejects. Copy it to a private location with 600 permissions.
        install -m 600 /run/secrets/vagrant_private_key "${WORKSPACE}/.vagrant_private_key"

        # Fail fast with a clear error if the VM is unreachable.
        # Uses the VM's static host-only IP (192.168.56.10, port 22) which bypasses
        # VirtualBox NAT entirely and is directly reachable from Docker containers.
        if ! timeout 10 bash -lc '</dev/tcp/192.168.56.10/22' 2>/dev/null; then
            echo "ERROR: Cannot reach 192.168.56.10:22 (VM host-only IP) from Jenkins container."
            echo "Ensure the Vagrant VM is running with the private_network adapter active."
            echo "If the VM was already up when the Vagrantfile was changed, run: vagrant reload"
            exit 2
        fi

        ANSIBLE_HOST_KEY_CHECKING=False \
        ansible-playbook \
            -i infra/ansible/inventory.ini \
            infra/ansible/deploy.yml \
            --extra-vars "app_jar_path=${WORKSPACE}/forked_code/target/spring-petclinic-4.0.0-SNAPSHOT.jar" \
            --extra-vars "ansible_ssh_private_key_file=${WORKSPACE}/.vagrant_private_key"
    '''

    def prometheusTarget = load 'groovy/prometheus-target.groovy'
    prometheusTarget.setPrometheusTarget('host.docker.internal:8082', 'production')
}

return deploy()
