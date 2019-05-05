String buildShell = "${env.buildShell}"
String targetHosts = "${env.targetHosts}"
String targetDir = "${env.targetDir}"
String serviceName = "${env.serviceName}"
String user = "${env.user}"


node("master"){
    stage("checkout"){
        checkout scm
    }
    
    stage("build"){   
        sh """ 
               export GOPATH=/usr/local/go
               export PATH=$PATH:\$GOPATH/bin
               ${buildShell}
               mkdir -p /srv/salt/${serviceName} 
               tar zcf ${serviceName}.tar.gz main static service.sh 
               rm -fr /srv/salt/${serviceName}/*
               mv ${serviceName}.tar.gz /srv/salt/${serviceName} 
           """
    }
    
    stage("deploy"){
        sh " salt ${targetHosts} cmd.run ' rm -fr  ${targetDir}/* '"
        sh " salt ${targetHosts} cp.get_file salt://${serviceName}/${serviceName}.tar.gz  ${targetDir}/${serviceName}.tar.gz mkdirs=True"
        sh " salt ${targetHosts} cmd.run 'chown ${user}:${user} ${targetDir} -R '"
        sh " salt ${targetHosts} cmd.run 'su - ${user} -c \" cd ${targetDir} && tar zxf ${serviceName}.tar.gz \" '"
        sh " salt ${targetHosts} cmd.run 'su - ${user} -c \"cd ${targetDir} &&  sh service.sh stop\" ' "
        sh " salt ${targetHosts} cmd.run 'su - ${user} -c \"cd ${targetDir} &&  sh service.sh start ${targetDir}\" ' "
    }


}
