import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import hudson.security.AuthorizationStrategy
import hudson.security.SecurityRealm
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob

def jenkins = Jenkins.get()
jenkins.setSecurityRealm(SecurityRealm.NO_AUTHENTICATION)
jenkins.setAuthorizationStrategy(AuthorizationStrategy.UNSECURED)
jenkins.save()

if (jenkins.getItem('petclinic-pipeline') == null) {
    def job = jenkins.createProject(WorkflowJob, 'petclinic-pipeline')
    def scm = new GitSCM('https://github.com/siddvoh/spring-petclinic-dev-pipeline.git')
    scm.branches = [new BranchSpec('*/main')]
    job.definition = new CpsScmFlowDefinition(scm, 'Jenkinsfile')
    job.save()
    job.scheduleBuild2(0)
}
