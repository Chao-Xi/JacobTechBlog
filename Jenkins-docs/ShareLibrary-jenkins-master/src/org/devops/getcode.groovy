package org.devops

//代码检出
def GetCode(srcType,srcUrl,tagName,branchName,credentialsId) {
    //delete 'origin/'
    if (branchName.startsWith('origin/')){
        branchName=branchName.minus("origin/")
    } 
    
    if(tagName == "null"){
        pathName = "*/${branchName}"
    }else{
        pathName = "refs/tags/${tagName}"
    }
    checkout([$class: 'GitSCM', branches: [[name: "${pathName}"]], 
        doGenerateSubmoduleConfigurations: false, 
        extensions: [], submoduleCfg: [], 
        userRemoteConfigs: [[credentialsId: "${credentialsId}", 
        url: "${srcUrl}"]]])
}
