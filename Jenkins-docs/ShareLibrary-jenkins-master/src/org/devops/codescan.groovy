package org.devops


//代码扫描
def SonarScan(projectType,skipSonar,srcDir,serviceName,scanDir){
    def scanHome = "/usr/local/sonar-scanner"
    if (projectType == 'java'){
        if ("${buildType}" == 'gradle'){
            codepath = 'build/classes'
        } else{
            codepath = 'target/classes'
        }
        try {
            sh """
                cd ${srcDir} 
                ${scanHome}/bin/sonar-scanner -Dsonar.projectName=${serviceName} -Dsonar.projectKey=${serviceName}  \
                -Dsonar.sources=.  -Dsonar.language=java -Dsonar.sourceEncoding=UTF-8 \
                -Dsonar.java.binaries=${codepath} -Dsonar.java.coveragePlugin=jacoco \
                -Dsonar.jacoco.reportPath=target/jacoco.exec -Dsonar.junit.reportsPath=target/surefire-reports \
                -Dsonar.surefire.reportsPath=target/surefire-reports -Dsonar.projectDescription='devopsdevops'
             """ 
        } catch (e){
            currentBuild.description="代码扫描失败!"
            error '代码扫描失败!'
        }
    } else if (projectType == 'web'){
        try {
            sh  """
                cd ${srcDir} 
                ${scanHome}/bin/sonar-scanner -Dsonar.projectName=${serviceName} \
                -Dsonar.projectKey=${serviceName} -Dsonar.sources=${scanDir} -Dsonar.language=js  
                cd - 
                """
        } catch (e){
            currentBuild.description="代码扫描失败!"
            error '代码扫描失败!'
        }
    }
}
