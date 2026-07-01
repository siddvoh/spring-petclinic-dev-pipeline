/* 
runs dynamic application security testing using OWASP ZAP 
and generates a report.

Ports are blocked so that none of the containers can be 
accessed from the host machine while ZAP is "attacking"
*/
def runZAPAnalysis() {

    sh 'mkdir -p ./zap/reports'
    sh 'docker-compose -f "./infra/docker-compose.yml" -f "./infra/docker-compose-no-ports.yml" up -d app'
    sh 'docker-compose -f "./infra/docker-compose.yml" -f "./infra/docker-compose-no-ports.yml" run zap'
    sh 'docker-compose -f "./infra/docker-compose.yml" -f "./infra/docker-compose-no-ports.yml" down app'

    publishHTML(target: [
        reportDir: './zap/reports',
        reportFiles: 'petclinic-zap-report.html',
        reportName: 'ZAP Security Report'
    ])
}


return runZAPAnalysis()
