/*
Publishes the latest OWASP ZAP PASSIVE monitoring report to this build.

Monitoring runs entirely ON THE PRODUCTION VM (deployed by Ansible): a native
ZAP proxy daemon passively scans real traffic (nginx front door -> ZAP -> app),
and a systemd reporter regenerates the HTML report every 30s on the VM.

This build just fetches the newest report snapshot from the VM over SSH so it
can be published/archived, then finishes quickly.
*/
def runZAPMonitoring() {
    sh '''
        # The mounted Docker secret is world-readable; OpenSSH rejects that.
        # Copy it to a private location with 600 perms (same as deploy.groovy).
        install -m 600 /run/secrets/vagrant_private_key "${WORKSPACE}/.vagrant_private_key"

        mkdir -p zap/reports
        scp -P 2222 \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -i "${WORKSPACE}/.vagrant_private_key" \
            vagrant@host.docker.internal:/opt/petclinic/zap-reports/latest-monitor.html \
            zap/reports/latest-monitor.html
    '''
}

return runZAPMonitoring()