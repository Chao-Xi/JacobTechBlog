# Building Continuous Delivery pipelines with Jenkins 2


## What is CICD

### Continuous Integration

Team members integrate their work frequently. Commits are verified by automated builds and tests

### Continuous Delivery

Continuous delivery (CD or CDE) is a software engineering approach in which teams produce software in short cycles, ensuring that the software can be reliably released at any time and, when releasing the software, doing so manually.

### Continuous Deployment

Every change goes through the build/test pipeline and automatically gets put into production

### pipeline

An automated sequence of states to deliver software from version control to your users


 
## What's new in Jenkins 2 

* Better out-of-the-box experience
  *  Default set of plugins 
  *  Secured by default 
* Revamped UI
* Pipeline as code 
* In general: Tore code, less GUI, less state
* Drop-in upgrade, backwards compatible w/1.6


## Pipeline as code 

* Grows with you from simple to complex
* Handle lots of jobs without repetition
* Survives Jenkins restarts 
* Brings next level of reuse to Jenkins 


## Scripted vs. declarative pipeline 

### Scripted

* more flexible, better reuse, compact

### Declarative

* No Groovy experience necessary
* Syntax checking
* Linting via API and CLI 
* Visual editor (beta) 


### Scripted pipeline example

```
node('java8') { 

  stage('Configure') { 
     env.PATH = "${tool 'maven-3.3.9'}/bin:${env.PATH} "
   } 
  
  stage('Checkout') { 
     git 'https://github.com/bertjan/spring-boot-sample' 
   } 
 
 stage('Build') { 
     sh 'mvn -B -V -U -e clean package' 
  } 
 
 stage('Archive') { 
     junit allowEmptyResults: true, testResults: '**/target/**/TEST*.xml'
  } 
} 
```

### declarative pipeline example


```
pipeline { 
   agent { 
      node { 
         label 'java8' 
        } 
    } 
   tools { 
         maven 'maven-3.3.9' 
   } 
  
  stages { 
      stage('Checkout') { 
          steps { 
            git 'https://github.com/bertjan/spring-boot-sample' 
          } 
       }
      stage('Build') { 
       steps { 
          sh 'mvn -B -V -U -e clean package' 
       } 
      } 
     stage('Archive') { 
          steps { 
            junit(testResults: '**/target/**/TEST*.xml', allowEmptyResults: true)
     }
  }
 }
}
```


## Scripted pipeline 

```
node { 
   stage(' Configure') { 
     env.PATH = "${tool 'maven-3.3.9'}/bin:${env.PATH}" 
     version = '1.0.' + env.BUILD_NUMBER
     currentBuild.displayName = version 

    properties([ 
buildDiscarder(logRotator(artifactDaysToKeepStr: ", artifactNumToKeepStr: ",  [$class: 
GithubProjectProperty', displayName: ", projectUrlStr: 'https://github.com/bertjan/spring-
boot-sample']
pipelineTriggers([[Sclass: 1GitHubPushIriggerl]) 
])
}

   stage('Checkout') { 
     git 'https://github.com/bertjan/spring-boot-sample' 
   } 
   
   stage('Version') { 
   sh "echo \'\ninfo.build.version=\$version » src/main/resources/application.properties || true" 
   sh "mvn -B -V -U -e versions:set -DnewVersion=$version" 
} 
 
 stage('Build') { 
     sh 'mvn -B -V -U -e clean package' 
  } 
 
 stage('Archive') { 
     junit allowEmptyResults: true, testResults: '**/target/**/TEST*.xml'
  }
  
 stage('Deploy') { 
 // Depends on the 'Credentials Binding Plugin' 
 // (https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Binding+Plugin) 
withCredentials([[$class : 'UsernamePasswordMultiBinding', credentialsId: 'cloudfoundry', 
                  usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {  
        
   sh '''
        curl -L "https://cli.run.pivotaleio/stable?release=linux64-binary&source=github" | tar -zx 
        
        ./cf api https://apierunspivotal.io 
        ./cf auth $USERNAME $PASSWORD 
        ./cf target -o bertjan-demo -s development 
        ./cf push 
       '''
 		}
 	}
 }
```

## Pipeline syntax 

* Built-in syntax and snippet generator
* Groovy DSL definition (GDSL file) for IDE
* Pipeline reference: `https://jenkinsio/docipipeline/steps`
* Plugin documentation
* If all else fails: dive into the source 


### Archive build artifacts

```
archiveArtifacts artifacts: '**/target/*.jar'
```

### Email Notification

```
try { 
    // build steps here 
   } catch (e) { 
   
   currentBuild.result = "FAILED" 
   def subject = 'Build \" + env.JOB_NAME + '\' (branch \" + branch + 'failed in Jenkins' 
   def body = 'Build log is attached. Details: ' + env.BUILD_URL 
   def to = 'email@domain.com' 
   mail to: to, subject: subject, body: body, attachLog: true 
   throw e 
} 
```

### Including files, using constants

```
// File common/Constants.groovy: 
class Constants { 

 static final MAJOR_VERSION_NUMBER = '3.2.1'; 
 static final SONAR_URL = 'https://sonar.my.company.com'; 
} 
return this; 

// Jenkinsfile: 
load 'common/Constants.groovy' 
sh "mvn -B -V -U -e sonar:sonar -Dsonar.host.url=${Constants.SONAR_URL}' "
```


### Re-usable workflow step

```
// In file <some git repo>/src/my/company/package/SomeLibrary.groovy 
package my.company.package 

def someBuildStep() { 
// Some build step 
} 

// In Jenkinsfile: 
@Library('pipeline-library') 
import my.company.package.* 

def myLibrary = new SomeLibrary() 
myLibrary.someBuildStep() 
```

### parallel run on multiple node

```
stage('Checkout') { 
	git 'https://github.com/bertjan/spring-boot-sample' 
	stash excludes: 'build/', includes: '**', name: 'source' 
} 
stage ('Test') { 
	parallel 'unit': { 
		node { 
			// run unit tests 
			unstash 'source' 
			sh 'mvn test' 
			junit '**/build/test-results/*.xml' 
		} 
	}, 'integration': { 
	    node { 
	    // run integration tests 
	    unstash 'source' 
	    sh 'mvn integration-test' 
	    junit '**/build/test-results/*.xml' 
		} 
	} 
} 
```



