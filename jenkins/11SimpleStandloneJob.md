# Standlone Job and its Class for the job builder 


## Standlone Job `lic_ami_and_asg_update`

**groovy name `lic_ami_and_asg_update.groovy`**

```
import learnsaas.DeployToolJobBuilder
import learnsaas.parameters.TargetEnvironments

licAmiAsgUpdate = new DeployToolJobBuilder(
  name:'lic_ami_and_asg_update',
  description:'''Updates AMI and ASG without running chef-client first.
  If a small appserver root filesystem change is made (i.e. via knife ssh
  "role:learn_installer"), this is much faster than lic_upgrade.''',
  method:'lic_ami_and_asg_update',
  arguments:[
    'environment':'$ENVIRONMENT',
    'client-id':'$CLIENT_ID'
  ],
).build(this)

licAmiAsgUpdate.with {
  authenticationToken('build4mepls')
  throttleConcurrentBuilds {
       maxPerNode(1)
       maxTotal(24)
  }
  concurrentBuild()
  parameters {
    stringParam('CLIENT_ID',
      null,
      'The CLIENT_ID or "Identifying Tag" from CAPTain')
    choiceParam('ENVIRONMENT',
      TargetEnvironments.CHOICES,
      'The environment of the instance.')
    stringParam('JENKINS_EXECUTION_ID',
      null,
      'Used only for CAPTain callback notifications.')
  }
  logRotator {
    numToKeep(30)
  }
  wrappers {
      timestamps()
  }
}
```

* `import learnsaas.DeployToolJobBuilder` and `import learnsaas.parameters.TargetEnvironments` **import necessary class**
* `licAmiAsgUpdate = new DeployToolJobBuilder().build(this)` **We can add parameters to the parent class** 
* **Parameters**: `name`,`description `,`method`, `arguments: ['environment':'$ENVIRONMENT', 'client-id':'$CLIENT_ID']`. **Parameters include `string` and `map`**.
* `.build(this)` **run the object** 
* `licAmiAsgUpdate.with{}` build the jenkins job with **required configure**


## Class DeployToolJobBuilder 

```
package learnsaas

import learnsaas.common.Mesos
import learnsaas.common.Captain
import javaposse.jobdsl.dsl.DslFactory
import javaposse.jobdsl.dsl.Job
import groovy.text.SimpleTemplateEngine

/**
 * Deploy Tool Builder
 */
class DeployToolJobBuilder {
  String name
  String description
  String method
  Map arguments

  static final String SCRIPT='''#!/bin/bash
cd /app/cli
thor saas_learn:client:$method <% arguments.each{ arg, val -> print "--${arg} ${val} " } %>
'''

  Job build(DslFactory dslFactory) {
    SimpleTemplateEngine engine = new SimpleTemplateEngine()
    String script = engine.createTemplate(SCRIPT).make(
      [
        'method':method,
        'arguments':arguments,
      ]
    )
    Job job = dslFactory.job(name) {
      it.description this.description
      steps {
        shell(script)
      }
    }
    Mesos.runOnMesosSlave(job, 'mesos-deploy-tool')
    Captain.notifyCaptain(job)
    Captain.enableAuthenticationToken(job)
    job
  }
}
```

* imported `groovy.text.SimpleTemplateEngine` is used for 

```
 SimpleTemplateEngine engine = new SimpleTemplateEngine()
String script = engine.createTemplate(SCRIPT).make(
      [
        'method':method,
        'arguments':arguments,
      ]
    )

```

* `class DeployToolJobBuilder {}`
* **String `name`, `description`, `method` and Map `arguments`**
* `static final String SCRIPT = ''' '''` is used for bash script inside jenkins job
* `Job build(DslFactory dslFactory) { }` is the main function inside Class
* **Build the job with job name**

```
Job job = dslFactory.job(name) {
      it.description this.description
      steps {
        shell(script)
      }
    }
```







