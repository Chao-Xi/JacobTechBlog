String buildShell = "${env.buildShell}"
String targetHosts = "${env.targetHosts}"
String targetDir = "${env.targetDir}"
String serviceName = "${env.serviceName}"
String user = "${env.user}"
String port = "${env.port}"
def jarName

node("master"){
    stage("checkout"){
        checkout scm
    }
    
    stage("build"){
        def mvnHome = tool 'M3'
        sh " ${mvnHome}/bin/mvn ${buildShell} "
        
        jarName = sh returnStdout: true, script: "cd target && ls *.jar"
        jarName = jarName - "\n"
        sh "mkdir -p /srv/salt/${serviceName} && mv  service.sh target/${jarName} /srv/salt/${serviceName} "
    }
    
    stage("deploy"){
        sh " salt ${targetHosts} cmd.run ' rm -fr  ${targetDir}/*.jar '"
        sh " salt ${targetHosts} cp.get_file salt://${serviceName}/${jarName}  ${targetDir}/${jarName} mkdirs=True"
        sh " salt ${targetHosts} cp.get_file salt://${serviceName}/service.sh  ${targetDir}/service.sh mkdirs=True"
        sh " salt ${targetHosts} cmd.run 'chown ${user}:${user} ${targetDir} -R '"
        sh " salt ${targetHosts} cmd.run 'su - ${user} -c \"cd ${targetDir} &&  sh service.sh stop\" ' "
        sh " salt ${targetHosts} cmd.run 'su - ${user} -c \"cd ${targetDir} &&  sh service.sh start ${jarName} ${port} ${targetDir}\" ' "
    }


}
