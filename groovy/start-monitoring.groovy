/*
Starts the continuous passive-monitoring stack at the END of the pipeline, so
monitoring is deployed as part of CD rather than started manually:

  - app         : the application being fronted (kept up for the proxy)
  - zap-monitor : long-lived ZAP proxy daemon (passive scan only, no attacks)
  - zap-reporter: regenerates the passive-scan HTML report every 30s

Idempotent and NON-BLOCKING: 'up -d' returns immediately, so the build finishes
and monitoring keeps running in the background afterwards.
*/
def startMonitoring() {
  sh 'docker compose -f infra/docker-compose.yml up -d --build app zap-monitor zap-reporter'
}

return startMonitoring()
