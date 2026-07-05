def runZAPAnalysis() {
    sh 'docker compose -f infra/docker-compose.yml up -d --build app'
    sh 'docker compose -f infra/docker-compose.yml run --rm zap'
    sh 'mkdir -p zap/reports && cp /zap/reports/petclinic-zap-report.html zap/reports/'
}

return runZAPAnalysis()
