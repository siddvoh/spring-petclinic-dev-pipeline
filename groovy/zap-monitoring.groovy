/*
Publishes the latest OWASP ZAP PASSIVE monitoring report to this build.

Monitoring runs entirely ON THE PRODUCTION VM (deployed by Ansible): a native
ZAP proxy daemon passively scans real traffic (nginx front door -> ZAP -> app),
and a systemd reporter regenerates the HTML report every 30s on the VM.

This build fetches a recent set of timestamped report snapshots from the VM,
then builds an index page so one Jenkins build can show multiple reports.
*/
def runZAPMonitoring() {
    sh '''
        # The mounted Docker secret is world-readable; OpenSSH rejects that.
        # Copy it to a private location with 600 perms (same as deploy.groovy).
        install -m 600 /run/secrets/vagrant_private_key "${WORKSPACE}/.vagrant_private_key"

        mkdir -p zap/reports

        # 192.168.56.10:22 — VM's static host-only IP, bypasses VirtualBox NAT.
        SSH_OPTS="-p 22 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${WORKSPACE}/.vagrant_private_key"

        # Pull the latest 50 timestamped reports plus latest-monitor.html.
        ssh ${SSH_OPTS} vagrant@192.168.56.10 \
            "ls -1t /opt/petclinic/zap-reports/monitor-*.html 2>/dev/null | head -n 50" \
            > "${WORKSPACE}/.zap-report-list" || true

        if [ -s "${WORKSPACE}/.zap-report-list" ]; then
            while IFS= read -r remote_file; do
                [ -z "${remote_file}" ] && continue
                scp ${SSH_OPTS} "vagrant@192.168.56.10:${remote_file}" zap/reports/
            done < "${WORKSPACE}/.zap-report-list"
        fi

        scp ${SSH_OPTS} \
            vagrant@192.168.56.10:/opt/petclinic/zap-reports/latest-monitor.html \
            zap/reports/latest-monitor.html || true

        # Build an index page so publishHTML can expose multiple report files.
        {
            echo '<!doctype html>'
            echo '<html><head><meta charset="utf-8"><title>ZAP Passive Monitoring Reports</title></head><body>'
            echo '<h1>ZAP Passive Monitoring Reports</h1>'
            echo '<p>Newest first. These are snapshots fetched from production VM.</p>'
            echo '<ul>'
            if [ -f zap/reports/latest-monitor.html ]; then
                echo '<li><a href="latest-monitor.html">latest-monitor.html</a></li>'
            fi

            found=0
            for f in $(ls -1t zap/reports/monitor-*.html 2>/dev/null); do
                if [ -f "${f}" ]; then
                    base="$(basename "${f}")"
                    echo "<li><a href=\"${base}\">${base}</a></li>"
                    found=1
                fi
            done

            if [ "${found}" -eq 0 ] && [ ! -f zap/reports/latest-monitor.html ]; then
                echo '<li>No passive monitoring reports found yet.</li>'
            fi

            echo '</ul>'
            echo '</body></html>'
        } > zap/reports/index.html
    '''
}

return runZAPMonitoring()