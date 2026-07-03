FROM jenkins/jenkins:lts-jdk17

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV PRE_CLEAR_INIT_GROOVY_D=true

USER root

RUN apt-get update
RUN apt-get install -y ansible
RUN apt-get install -y docker.io
RUN apt-get install -y docker-compose
RUN apt-get install -y git
RUN apt-get install -y openssh-client

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY create-job.groovy /usr/share/jenkins/ref/init.groovy.d/create-job.groovy
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
