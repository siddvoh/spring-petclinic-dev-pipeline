def runZAPAnalysis() {
    sh 'docker compose -f infra/docker-compose.yml up -d --build app'
    sh 'docker compose -f infra/docker-compose.yml run --rm zap'
    sh '''
        set -euo pipefail

        REPORT_SRC_DIR="/zap/reports"
        REPORT_DST_DIR="zap/reports"
        mkdir -p "${REPORT_DST_DIR}"

        # Keep a timestamped snapshot so active-scan reports do not overwrite each other.
        ts="$(date -u +%Y%m%d-%H%M%S)"
        cp "${REPORT_SRC_DIR}/petclinic-zap-report.html" "${REPORT_SRC_DIR}/petclinic-zap-report-${ts}.html"

        # Pull all timestamped snapshots plus the latest fixed-name report into workspace.
        cp -f "${REPORT_SRC_DIR}"/petclinic-zap-report*.html "${REPORT_DST_DIR}/" 2>/dev/null || true

        # Publish a clickable list in Jenkins so all saved snapshots are visible.
        {
            echo '<!doctype html>'
            echo '<html><head><meta charset="utf-8"><title>ZAP Active Scan Reports</title></head><body>'
            echo '<h1>ZAP Active Scan Reports</h1>'
            echo '<p>Newest first. Timestamped snapshots are retained across runs.</p>'
            echo '<ul>'
            if [ -f "${REPORT_DST_DIR}/petclinic-zap-report.html" ]; then
                echo '<li><a href="petclinic-zap-report.html">petclinic-zap-report.html (latest)</a></li>'
            fi
            found=0
            for f in $(ls -1t "${REPORT_DST_DIR}"/petclinic-zap-report-*.html 2>/dev/null); do
                if [ -f "${f}" ]; then
                    base="$(basename "${f}")"
                    echo "<li><a href=\"${base}\">${base}</a></li>"
                    found=1
                fi
            done
            if [ "${found}" -eq 0 ] && [ ! -f "${REPORT_DST_DIR}/petclinic-zap-report.html" ]; then
                echo '<li>No active scan reports found.</li>'
            fi
            echo '</ul>'
            echo '</body></html>'
        } > "${REPORT_DST_DIR}/index.html"
    '''
}

return runZAPAnalysis()
