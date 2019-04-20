# SAP onsite interview

### 1.Jenkins how to turn Bash output variable to Jenkins Variable

```
def PRIVATE_RDS = sh(returnStdout: true,
                     script: '''#!/bin/bash
                     			  set -e
                     			  ...
                     			  echo $PRIVATE_RDS''').trim()
```


### 2.Jenkins Library and Directory 

```
@Library('bb-operations') pipelineLibrary
```

```
$ tree -L 2
.
├── README.md
├── dsl-jobs
│   └── operation-jenkins
├── idea.gdsl
├── resources
│   └── bbops-jenkins:  Kubernetes and pipeline-configuration
├── src
│   ├── bbopsCommon
│   └── bbopsEnv
├── vars
│   ├── bbops_build_debug_client_id.groovy
|    ...
└── workflow
```

### 3. In Jenkins Directory, difference between `vars` and `src`

**In vars:**

* Common functions are called inside groovy files
* Var can also call functions from `src`

**In src:**

Env variables :=>  `static final variable_name`

```
package bbopsEnv
```

### 4.Python Virtual Env

[Python 虚拟环境学习](https://github.com/Chao-Xi/JacobTechBlog/blob/master/Python/PythonVirtualEnv.md)

### 5.Grafana data persistent

[Grafana 在 Kubernetes 中的使用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/8Adv_K8S_Grafana.md)






                    
                     