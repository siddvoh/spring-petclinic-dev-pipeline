def buildAndTest() {
    dir('forked_code') {
        sh './mvnw -B clean package'
    }
}

return buildAndTest()
