package org.devops


//saltapi模板
def Salt(salthost,saltfunc,saltargs) {
    /*result = salt(authtype: 'pam', 
                clientInterface: local( arguments: saltargs,
                                        function: saltfunc, 
                                        target: salthost, 
                                        targettype: 'list'),
                credentialsId: "f89abde3-49f0-4b75-917e-c4e49c483f4f", 
                servername: "http://127.0.0.1:9000")*/
    
    sh """
        salt ${salthost} ${saltfunc} ${saltargs}
        """
    //println(result)
    //PrintMes(result,'blue')
    //return  result
}


//前端类型发布
def WebDeploy(user,serviceName,targetDir){
    try {
        println('清空发布目录')
        
        Salt(targetHosts,'cmd.run', "cmd=\" rm -fr  ${targetDir}/* \"")
        
        println('发布软件包')
        Salt(targetHosts,'cp.get_file', "salt://${JOB_NAME}/${serviceName}.tar.gz ${targetDir}/${serviceName}.tar.gz makedirs=True ")
        sleep 2;
        
        println('解压')
        Salt(targetHosts,'cmd.run', "cmd=\" cd ${targetDir} && tar zxf ${serviceName}.tar.gz  \"")
        sleep 2;
        
        println('授权')
        Salt(targetHosts,'cmd.run', "cmd=\"chown ${user}:${user} ${targetDir} -R  \"")
        sleep 2;
        println('获取发布文件')
        Salt(targetHosts,'cmd.run', "cmd=\" ls -l  ${targetDir} \"")
        
        println('删除缓存文件')
        sh "rm -fr /srv/salt/${JOB_NAME}/*"
    } catch (e){
        currentBuild.description='包发布失败！'
        error '包发布失败！'
    }
}

