/*
Publishes the latest OWASP ZAP PASSIVE monitoring report to this build.

The actual monitoring runs continuously OUTSIDE Jenkins: a long-lived ZAP proxy
daemon (zap-monitor) passively scans traffic, and a sidecar (zap-reporter)
regenerates the HTML report every 30s into the shared zap_reports volume.

This build just ensures those services are up, copies the newest report snapshot
into the workspace so it can be published/archived, and then FINISHES quickly.
*/
def runZAPMonitoring() {
    // Idempotent: starts the persistent proxy + reporter if they aren't already running.
    sh 'docker compose -f infra/docker-compose.yml up -d --build zap-monitor zap-reporter'

    // The Jenkins container mounts the shared zap_reports volume at /zap/reports,
    // where the sidecar writes latest-monitor.html every ~30s.
    sh '''
        mkdir -p zap/reports
        if [ -f /zap/reports/latest-monitor.html ]; then
            cp /zap/reports/latest-monitor.html zap/reports/latest-monitor.html
        else
            echo "No monitoring report yet - the zap-reporter sidecar may still be warming up."
        fi
    '''
}

return runZAPMonitoring()