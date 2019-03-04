# Multiple Inheritance Job in pipeline job (lock and unlock parts)

## In first layer pipeline job (lock and unlock parts)

### Call the class `InstanceLockerJobBuilder`

`learn-saas/jenkins/jobs_lcjenkins_saas/ami_update_pipeline/ami_update_pipeline.groovy`

```
import learnsaas.InstanceLockerJobBuilder
final String PREFIX = 'AMIUpdate'

Job lockInstance = new InstanceLockerJobBuilder(
    name:"${PREFIX}-lock-instance",
    description:'check if instance is locked then lock',
).build(this)

lockInstance.with {
  throttleConcurrentBuilds {
       categories(['AMIUpdatePipelineCategory'])
  }
  concurrentBuild()
  steps {
    shell('''#!/bin/bash
set -e
learn-instance-locker instance-check-and-lock --client-id $CLIENT_ID --fleet $FLEET
''')
  }
}

// Start Pipeline jobs
...
// End Pipeline jobs

Job unlockInstance = new InstanceLockerJobBuilder(
    name:"${PREFIX}-unlock-instance",
    description:'check if instance is locked then lock',
).build(this)

unlockInstance.with {
  throttleConcurrentBuilds {
       categories(['AMIUpdatePipelineCategory'])
  }
  concurrentBuild()
  steps {
    shell('''#!/bin/bash
set -e
learn-instance-locker instance-unlock --client-id $CLIENT_ID --fleet $FLEET
''')
  }
}

// Pipeline jobs list view
listView(PREFIX) {
	description('All AMIUpdate related jobs.')
   filterBuildQueue()
   filterExecutors()
   jobs {
      name(lockInstance.name)
      ...
      name(unlockInstance.name)
   }
   columns {
        status()
        weather()
        name()
        lastDuration()
    }
}

// Pipeline plumbing
 ... 
```

## Second layer class `InstanceLockerJobBuilder`

`learn-saas/jenkins/src/main/groovy/learnsaas`

### Call the class `LearnSaasClientJobBuilder`

```
package learnsaas

import javaposse.jobdsl.dsl.DslFactory
import javaposse.jobdsl.dsl.Job

/**
 * Learn Saas Image Updator Builder
 */
class InstanceLockerJobBuilder {
  String name
  String description

  Job build(DslFactory dslFactory) {
    
    Job job = new LearnSaasClientJobBuilder(
      name:this.name,
      description:this.description,
    ).build(dslFactory)

    job.with {
      environmentVariables {
        env('CAPTAIN_SITE', '...')
      }

      wrappers {
        credentialsBinding {
          usernamePassword('CAPTAIN_USERNAME', 'CAPTAIN_PASSWORD', '...')
        }
      }
    }

    job
  }
}
```

#### `environmentVariables` and `credentialsBinding`

```
job.with {
      environmentVariables {
        env('CAPTAIN_SITE', '...')
      }

      wrappers {
        credentialsBinding {
          usernamePassword('CAPTAIN_USERNAME', 'CAPTAIN_PASSWORD', '...')
        }
      }
    }
```

#### Return job

```
Job build(DslFactory dslFactory) {
	
   Job job = new LearnSaasClientJobBuilder(
      name:this.name,
      description:this.description,
    ).build(dslFactory)
    
    job.with { }
    
    job
  }
}
```

## Third layer class `LearnSaasClientJobBuilder`

```
package learnsaas

import learnsaas.common.Mesos
import learnsaas.common.Captain
import javaposse.jobdsl.dsl.DslFactory
import javaposse.jobdsl.dsl.Job

/**
 * LearnSaas Tool Builder
 */
class LearnSaasClientJobBuilder {
  String name
  String description

  Job build(DslFactory dslFactory) {
    Job job = dslFactory.job(name) {
      it.description this.description
    }
    Mesos.runOnMesosSlave(job, 'mesos-learn-saas')
    Captain.notifyCaptain(job)
    Captain.enableAuthenticationToken(job)
    job
  }
}
```

#### description:

```
Job job = dslFactory.job(name) {
      it.description this.description
    }
```