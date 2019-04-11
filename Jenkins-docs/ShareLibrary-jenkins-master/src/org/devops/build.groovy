package org.devops

//构建打包
def Build(javaVersion,buildType,buildDir,buildShell){
    if (buildType == 'maven'){
        Home = tool '/usr/local/apache-maven'
        buildHome = "${Home}/bin/mvn"
    } else if (buildType == 'ant'){
        Home = tool 'ANT'
        buildHome = "${Home}/bin/ant"
    } else if (buildType == 'gradle'){
        buildHome = '/usr/local/bin/gradle'
    } else{
        error 'buildType Error [maven|ant|gradle]'
    }
    echo "BUILD_HOME: ${buildHome}"
    
    //选择JDK版本
    jdkPath = ['jdk7' : '/usr/local/jdk1.7.0_79',
               'jdk6' : '/usr/local/jdk1.6.0_45',
               'jdk8' : '/usr/java/jdk1.8.0_111',
               'jdk11': '/usr/local/jdk-11.0.1',
               'null' : '/usr/java/jdk1.8.0_111']
    def javaHome = jdkPath["$javaVersion"]
    if ("$javaVersion" == 'jdk11'){
       sh  """
        export JAVA_HOME=${javaHome}
        export PATH=\$JAVA_HOME/bin:\$PATH
        java -version
        cd ${buildDir} && ${buildHome} ${buildShell}
        """
    } else {
        sh  """
            export JAVA_HOME=${javaHome}
            export PATH=\$JAVA_HOME/bin:\$PATH
            export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
            java -version
            cd ${buildDir} && ${buildHome} ${buildShell}
            """
    }
}


//前端Build
def WebBuild(srcDir,serviceName){
    def deployPath = "/srv/salt/${JOB_NAME}"
    sh """
        [ -d ${deployPath} ] || mkdir -p ${deployPath}
        cd ${srcDir}/
        rm -fr *.tar.gz 
        tar zcf ${serviceName}.tar.gz * 
        cp ${serviceName}.tar.gz ${deployPath}/${serviceName}.tar.gz
        cd -
    """
}