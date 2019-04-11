package org.devops


//格式化输出
def PrintMes(value,color){
    colors = ['red'   : "\033[40;31m >>>>>>>>>>>${value}<<<<<<<<<<< \033[0m",
              'blue'  : "\033[47;34m ${value} \033[0m",
              'green' : "[1;32m>>>>>>>>>>${value}>>>>>>>>>>[m",
              'green1' : "\033[40;32m >>>>>>>>>>>${value}<<<<<<<<<<< \033[0m" ]
    ansiColor('xterm') {
        println(colors[color])
    }
}


//获取源码目录
def BuildDir(workspace,srcType,tagName,moduleName) {
    def srcDir = workspace
    if(srcType == "Git") {
        buildDir = "${workspace}"
        if(moduleName == "null"){
            srcDir = "${workspace}"
        }else{
            srcDir = "${workspace}/${moduleName}"
        }
    }else{
        if(tagName == "null") {
            def srcTmp = srcUrl.split("/")[-1]
            srcDir = "${workspace}/${srcTmp}"
        }else{
            srcDir = "${workspace}/${tagName}"
        }
    }
    buildDir = srcDir
    return [buildDir,srcDir]
}

//saltapi模板
def Salt(salthost,saltfunc,saltargs) {
    result = salt(authtype: 'pam', 
                clientInterface: local( arguments: saltargs,
                                        function: saltfunc, 
                                        target: salthost, 
                                        targettype: 'list'),
                credentialsId: "c4ec3410-7f97-40fa-8ad9-be38a7bbbcd8", 
                servername: "http://127.0.0.1:8000")
    println(result)
    //PrintMes(result,'blue')
    return  result
}






