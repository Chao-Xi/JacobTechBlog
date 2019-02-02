# Controlling the Flow with Stage, Lock, and Milestone 

Recently the Pipeline team began making several changes to improve the **stage step** and increase control of concurrent builds in Pipeline. Until **now the stage step** has been the catch-all for functionality related to the flow of builds through the Pipeline: grouping build steps into visualized stages, limiting concurrent builds, and discarding stale builds.

In order to improve upon each of these areas independently we decided to break this functionality into discrete steps rather than push more and more features into an already packed **stage** step.

* **stage** - the stage step remains but is now focused on grouping steps and providing boundaries for Pipeline segments.
* **lock** - the lock step throttles the number of concurrent builds in a defined section of the Pipeline.
* **milestone** - the milestone step automatically discards builds that will finish out of order and become stale.


Separating these concerns into explicit, independent steps allows for much greater control of Pipelines and broadens the set of possible use cases.

## Stage

The **stage** step is a primary building block in Pipeline, dividing the steps of a Pipeline into explicit units and helping to visualize the progress using the "**Stage View**" plugin or "Blue Ocean". Beginning with version 2.2 of "Pipeline Stage Step" plugin, the **stage** step now requires a block argument, wrapping all steps within the defined stage. This makes the boundaries of where each stage begins and ends obvious and predictable. In addition, the concurrency argument of **stage** has now been removed to make this step more concise; responsibility for concurrency control has been delegated to the **lock** step.

```
stage('Build') {
  doSomething()
  sh "echo $PATH"
}
```

**Omitting the block from stage and using the concurrency argument are now deprecated in Pipeline**. Pipelines using this syntax will continue to function but will produce a warning in the console log:

```
Using the 'stage' step without a block argument is deprecated
```

This message is only a reminder to update your Pipeline scripts; none of your Pipelines will stop working. If we reach a point where the old syntax is to be removed we will make an announcement prior to the change. We do, however, recommend that you update your existing Pipelines to utilize the new syntax.

note: Stage View and Blue Ocean will both work with either the old **stage** syntax or the new.

## Lock

Rather than attempt to limit the number of concurrent builds of a job using the **stage**, we now rely on the "Lockable Resources" plugin and the **lock** step to control this. The **lock** step limits concurrency to a single build and it provides much greater flexibility in designating where the concurrency is limited.


* **lock** can be used to constrain an entire **stage** or just a segment:

```
stage('Build') {
  doSomething()
  lock('myResource') {
    echo "locked build"
  }
}
```

* **lock** can be also used to wrap multiple stages into a single concurrency unit:

```
lock('myResource') {
  stage('Build') {
    echo "Building"
  }
  stage('Test') {
    echo "Testing"
  }
}

```

## Milestone

The **milestone** step is the last piece of the puzzle to replace functionality originally intended for **stage** and adds even more control for handling concurrent builds of a job. 

The **lock** step limits the number of builds running concurrently in a section of your 

**Pipeline while the milestone step ensures that older builds of a job will not overwrite a newer build.**

### Concurrent builds of the same job do not always run at the same rate. 

Depending on the network, the node used, compilation times, test times, etc. 

### it is always possible for a newer build to complete faster than an older build. 

For example:

* Build 1 is triggered
* Build 2 is triggered
* Build 2 builds faster than Build 1 and enters the Test stage sooner.

**Rather than allowing Build 1 to continue and possibly overwrite the newer artifact produced in Build 2, you can use the milestone step to abort Build 1**:

```
stage('Build') {
  milestone()
  echo "Building"
}
stage('Test') {
  milestone()
  echo "Testing"
}
```

When using the **input** step or the lock step a backlog of concurrent builds can easily stack up, either waiting for user input or waiting for a resource to become free. The **milestone** step will automatically prune all older jobs that are waiting at these junctions.


```
milestone()
input message: "Proceed?"
milestone()
```

Bookending an **input** step like this allows you to select a specific build to proceed and automatically abort all antecedent builds.


```
milestone()
lock(resource: 'myResource', inversePrecedence: true) {
  echo "locked step"
  milestone()
}
```

### Similarly a pair of **milestone** steps used with a **lock** will discard all old builds waiting for a shared resource. 

In this example, `inversePrecedence: true` instructs the lock to begin most recent waiting build first, ensuring that the most recent code takes precedence.

## Putting it all together

Each of these steps can be used independently of the others to control one aspect of a Pipeline or they can be combined to provide powerful, fine-grained control of every aspect of multiple concurrent builds flowing through a Pipeline. Here is a very simple example utilizing all three:

```
stage('Build') {
  // The first milestone step starts tracking concurrent build order
  milestone()
  node {
    echo "Building"
  }
}

// This locked resource contains both Test stages as a single concurrency Unit.
// Only 1 concurrent build is allowed to utilize the test resources at a time.
// Newer builds are pulled off the queue first. When a build reaches the
// milestone at the end of the lock, all jobs started prior to the current
// build that are still waiting for the lock will be aborted
lock(resource: 'myResource', inversePrecedence: true){
  node('test') {
    stage('Unit Tests') {
      echo "Unit Tests"
    }
    stage('System Tests') {
      echo "System Tests"
    }
  }
  milestone()
}

// The Deploy stage does not limit concurrency but requires manual input
// from a user. Several builds might reach this step waiting for input.
// When a user promotes a specific build all preceding builds are aborted,
// ensuring that the latest code is always deployed.
stage('Deploy') {
  input "Deploy?"
  milestone()
  node {
    echo "Deploying"
  }
}
```

## Reference: 

* `https://jenkins.io/blog/2016/10/16/stage-lock-milestone/`
* `https://www.quernus.co.uk/2016/10/19/lockable-resources-jenkins-pipeline-builds/`

## Example:

```
#!/usr/bin/env groovy
@Library('StanUtils')
import org.stan.Utils

def runTests(String testPath) {
    sh "./runTests.py -j${env.PARALLEL} ${testPath} --make-only"
    try { sh "./runTests.py -j${env.PARALLEL} ${testPath}" }
    finally { junit 'test/**/*.xml' }
}

def utils = new org.stan.Utils()

def isBranch(String b) { env.BRANCH_NAME == b }

String alsoNotify() {
    if (isBranch('master') || isBranch('develop')) {
        "stan-buildbot@googlegroups.com"
    } else ""
}
Boolean isPR() { env.CHANGE_URL != null }
String fork() { env.CHANGE_FORK ?: "stan-dev" }
String branchName() { isPR() ? env.CHANGE_BRANCH :env.BRANCH_NAME }
String cmdstan_pr() { params.cmdstan_pr ?: "downstream_tests" }
String stan_pr() { params.stan_pr ?: "downstream_tests" }

pipeline {
    agent none
    parameters {
        string(defaultValue: 'downstream_tests', name: 'cmdstan_pr',
          description: 'PR to test CmdStan upstream against e.g. PR-630')
        string(defaultValue: 'downstream_tests', name: 'stan_pr',
          description: 'PR to test Stan upstream against e.g. PR-630')
        booleanParam(defaultValue: false, description:
        'Run additional distribution tests on RowVectors (takes 5x as long)',
        name: 'withRowVector')
    }
    options {
        skipDefaultCheckout()
        preserveStashes(buildCount: 7)
    }
    stages {
        stage('Kill previous builds') {
            when {
                not { branch 'develop' }
                not { branch 'master' }
            }
            steps {
                script {
                    utils.killOldBuilds()
                }
            }
        }
        stage("Clang-format") {
            agent any
            steps {
                sh "printenv"
                deleteDir()
                retry(3) { checkout scm }
                withCredentials([usernamePassword(credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b',
                    usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh """#!/bin/bash
                        set -x
                        git checkout -b ${branchName()}
                        clang-format --version
                        find stan test -name '*.hpp' -o -name '*.cpp' | xargs -n20 -P${env.PARALLEL} clang-format -i
                        if [[ `git diff` != "" ]]; then
                            git config --global user.email "mc.stanislaw@gmail.com"
                            git config --global user.name "Stan Jenkins"
                            git add stan test
                            git commit -m "[Jenkins] auto-formatting by `clang-format --version`"
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${fork()}/math.git ${branchName()}
                            echo "Exiting build because clang-format found changes."
                            echo "Those changes are now found on stan-dev/math under branch ${branchName()}"
                            echo "Please 'git pull' before continuing to develop."
                            exit 1
                        fi"""
                }
            }
            post {
                always { deleteDir() }
                failure {
                    script {
                        emailext (
                            subject: "[StanJenkins] Autoformattted: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                            body: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' " +
                                "has been autoformatted and the changes committed " +
                                "to your branch, if permissions allowed." +
                                "Please pull these changes before continuing." +
                                "\n\n" +
                                "See https://github.com/stan-dev/stan/wiki/Coding-Style-and-Idioms" +
                                " for setting up the autoformatter locally.\n"+
                            "(Check console output at ${env.BUILD_URL})",
                            recipientProviders: [[$class: 'RequesterRecipientProvider']],
                            to: "${env.CHANGE_AUTHOR_EMAIL}"
                        )
                    }
                }
            }
        }
        stage('Linting & Doc checks') {
            agent any
            steps {
                script {
                    deleteDir()
                    retry(3) { checkout scm }
                    sh "git clean -xffd"
                    stash 'MathSetup'
                    sh "echo CC=${env.CXX} -Werror > make/local"
                    parallel(
                        CppLint: { sh "make cpplint" },
                        Dependencies: { sh 'make test-math-dependencies' } ,
                        Documentation: { sh 'make doxygen' },
                    )
                }
            }
            post {
                always {
                    warnings consoleParsers: [[parserName: 'CppLint']], canRunOnFailed: true
                    warnings consoleParsers: [[parserName: 'math-dependencies']], canRunOnFailed: true
                    deleteDir()
                }
            }
        }
        stage('Headers check') {
            agent any
            steps {
                deleteDir()
                unstash 'MathSetup'
                sh "echo CC=${env.CXX} -Werror > make/local"
                sh "make -j${env.PARALLEL} test-headers"
            }
            post { always { deleteDir() } }
        }
        stage('Linux Unit with MPI') {
            agent { label 'linux' }
            steps {
                deleteDir()
                unstash 'MathSetup'
                sh "echo CC=${MPICXX} >> make/local"
                sh "echo STAN_MPI=true >> make/local"
                runTests("test/unit")
            }
            post { always { retry(3) { deleteDir() } } }
        }
        stage('Always-run tests') {
            parallel {
                stage('Distribution tests') {
                    agent { label "distribution-tests" }
                    steps {
                        deleteDir()
                        unstash 'MathSetup'
                        sh """
                            echo CC=${env.CXX} > make/local
                            echo 'O=0' >> make/local
                            echo N_TESTS=${env.N_TESTS} >> make/local
                            """
                        script {
                            if (params.withRowVector || isBranch('develop') || isBranch('master')) {
                                sh "echo CXXFLAGS+=-DSTAN_TEST_ROW_VECTORS >> make/local"
                            }
                        }
                        sh "./runTests.py -j${env.PARALLEL} test/prob > dist.log 2>&1"
                    }
                    post {
                        always {
                            script { zip zipFile: "dist.log.zip", archive: true, glob: 'dist.log' }
                            retry(3) { deleteDir() }
                        }
                        failure {
                            echo "Distribution tests failed. Check out dist.log.zip artifact for test logs."
                        }
                    }
                }
                stage('Mac Unit with Threading') {
                    agent  { label 'osx' }
                    steps {
                        deleteDir()
                        unstash 'MathSetup'
                        sh "echo CC=${env.CXX} -Werror > make/local"
                        sh "echo CXXFLAGS+=-DSTAN_THREADS >> make/local"
                        runTests("test/unit")
                    }
                    post { always { retry(3) { deleteDir() } } }
                }
            }
        }
        stage('Additional merge tests') {
            when { anyOf { branch 'develop'; branch 'master' } }
            parallel {
                stage('Unit with GPU') {
                    agent { label "gelman-group-mac" }
                    steps {
                        deleteDir()
                        unstash 'MathSetup'
                        sh "echo CC=${env.CXX} -Werror > make/local"
                        sh "echo STAN_OPENCL=true>> make/local"
                        sh "echo OPENCL_PLATFORM_ID=0>> make/local"
                        sh "echo OPENCL_DEVICE_ID=0>> make/local"
                        runTests("test/unit")
                    }
                    post { always { retry(3) { deleteDir() } } }
                }
                stage('Linux Unit with Threading') {
                    agent { label 'linux' }
                    steps {
                        deleteDir()
                        unstash 'MathSetup'
                        sh "echo CC=${GCC} >> make/local"
                        sh "echo CXXFLAGS+=-DSTAN_THREADS >> make/local"
                        runTests("test/unit")
                    }
                    post { always { retry(3) { deleteDir() } } }
                }
            }
        }
        stage('Upstream tests') {
            when { expression { env.BRANCH_NAME ==~ /PR-\d+/ } }
            steps {
                build(job: "Stan/${stan_pr()}",
                        parameters: [string(name: 'math_pr', value: env.BRANCH_NAME),
                                    string(name: 'cmdstan_pr', value: cmdstan_pr())])
            }
        }
        stage('Upload doxygen') {
            agent any
            when { branch 'master'}
            steps {
                deleteDir()
                retry(3) { checkout scm }
                withCredentials([usernamePassword(credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b',
                                                  usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh """#!/bin/bash
                        set -x
                        make doxygen
                        git config --global user.email "mc.stanislaw@gmail.com"
                        git config --global user.name "Stan Jenkins"
                        git checkout --detach
                        git branch -D gh-pages
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/stan-dev/math.git :gh-pages
                        git checkout --orphan gh-pages
                        git add -f doc
                        git commit -m "auto generated docs from Jenkins"
                        git subtree push --prefix doc/api/html https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/stan-dev/math.git gh-pages
                        """
                }
            }
            post { always { deleteDir() } }
        }
    }
    post {
        always {
            node("osx || linux") {
                warnings canRunOnFailed: true, consoleParsers: [[parserName: 'Clang (LLVM based)']]
            }
        }
        success {
            script {
                utils.updateUpstream(env, 'stan')
                utils.mailBuildResults("SUCCESSFUL")
            }
        }
        unstable { script { utils.mailBuildResults("UNSTABLE", alsoNotify()) } }
        failure { script { utils.mailBuildResults("FAILURE", alsoNotify()) } }
    }
}
```

