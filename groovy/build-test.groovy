def buildAndTest() {
    def prometheusTarget = load 'groovy/prometheus-target.groovy'
    prometheusTarget.setPrometheusTarget('app:8080', 'ci')

    dir('forked_code') {
        sh './mvnw -B clean package'
    }
}

return buildAndTest()
