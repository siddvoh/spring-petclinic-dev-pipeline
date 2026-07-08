def setPrometheusTarget(String target, String environmentName) {
    sh """
        cat <<EOF > "${WORKSPACE}/.petclinic-prom-target.yml"
- targets: [\"${target}\"]
  labels:
    environment: \"${environmentName}\"
EOF

        docker cp "${WORKSPACE}/.petclinic-prom-target.yml" prometheus:/etc/prometheus/targets/petclinic-targets.yml

        # file_sd refresh picks this up automatically; this helps verify current value in logs.
        docker exec prometheus sh -c 'cat /etc/prometheus/targets/petclinic-targets.yml'
    """
}

return this
