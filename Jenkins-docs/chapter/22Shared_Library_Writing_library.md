# Writing libraries in Shared Library

At the base level, any valid Groovy code is okay for use. Different data structures, utility methods, etc, such as:

```
// src/org/foo/Point.groovy
package org.foo

// point in 3D space
class Point {
  float x,y,z
}
```

## Accessing steps

Library classes cannot directly call steps such as `sh` or `git`. 

They can however implement methods, outside of the scope of an enclosing class, which in turn invoke Pipeline steps, for example:

```
package org.foo

def checkOutFrom(repo) {
  git url: "git@github.com:jenkinsci/${repo}"
}

return this
```

Which can then be called from a **Scripted Pipeline:**


```
def z = new org.foo.Zot()
z.checkOutFrom(repo)
```

This approach has limitations; for example, **it prevents the declaration of a superclass**.

Alternately, a set of `steps` can be passed explicitly using `this` to a library class, in a constructor, or just one method:

```
package org.foo
class Utilities implements Serializable {
  def steps
  Utilities(steps) {this.steps = steps}
  def mvn(args) {
    steps.sh "${steps.tool 'Maven'}/bin/mvn -o ${args}"
  }
}
```

When saving state on classes, such as above, the class must implement the `Serializable` interface. This ensures that a Pipeline using the class, as seen in the example below, can properly suspend and resume in Jenkins.

```
@Library('utils') import org.foo.Utilities
def utils = new Utilities(this)
node {
  utils.mvn 'clean package'
}
```

If the library needs to access global variables, such as `env`, those should be explicitly passed into the library classes, or methods, in a similar manner.

Instead of passing numerous variables from the Scripted Pipeline into a library,

```
package org.foo
class Utilities {
  static def mvn(script, args) {
    script.sh "${script.tool 'Maven'}/bin/mvn -s ${script.env.HOME}/jenkins.xml -o ${args}"
  }
}
```


The above example shows the script being passed in to one `static` method, invoked from a Scripted Pipeline as follows:

```
@Library('utils') import static org.foo.Utilities.*
node {
  mvn this, 'clean package'
}
```

## Defining global variables

Internally, scripts in the `vars` directory are instantiated on-demand as singletons. This allows multiple methods to be defined in a single `.groovy`file for convenience. For example:

**`vars/log.groovy`**

```
def info(message) {
    echo "INFO: ${message}"
}

def warning(message) {
    echo "WARNING: ${message}"
}
```

**`Jenkinsfile`**

```
@Library('utils') _

log.info 'Starting'
log.warning 'Nothing to do!'
```

Note that if you wish to use a field in your global for some state, annotate it as such:

```
@groovy.transform.Field
def yourField = [:]

def yourFunction....
```

#### Declarative Pipeline does not allow method calls on objects outside "script" blocks. 

The method calls above would need to be put inside a script directive:

**Jenkinsfile**

```

@Library('utils') _

pipeline {
    agent none
    stage ('Example') {
        steps {
            // log.info 'Starting'      # 1
            script {                    # 2
                log.info 'Starting'   
                log.warning 'Nothing to do!'
            }
        }
    }
}
```

1. This method call would fail because it is outside a `script` directive.
2. `script` directive required to access global variables in Declarative Pipeline.


## Defining custom steps

Shared Libraries can also define global variables which behave similarly to built-in steps, such as `sh` or `git`. Global variables defined in Shared Libraries must be named with all lower-case or "camelCased" in order to be loaded properly by Pipeline. 

For example, to define `sayHello`, the file `vars/sayHello.groovy` should be created and should implement a `call` method. The `call` method allows the global variable to be invoked in a manner similar to a step:


**`vars/sayHello.groovy`**

```
// vars/sayHello.groovy
def call(String name = 'human') {
    // Any valid steps can be called from this code, just like in other
    // Scripted Pipeline
    echo "Hello, ${name}."
}
```


The Pipeline would then be able to reference and invoke this variable:


```
sayHello 'Joe'
sayHello() /* invoke with default arguments */
```

If called with a block, the `call` method will receive a Closure. The type should be defined explicitly to clarify the intent of the step, for example:

**`vars/windows.groovy`**

```
// vars/windows.groovy
def call(Closure body) {
    node('windows') {
        body()
    }
}
```

The Pipeline can then use this variable like any built-in step which accepts a block:

```
windows {
    bat "cmd /?"
}
```


## Defining a more structured DSL

If you have a lot of Pipelines that are mostly similar, the global variable mechanism provides a handy tool to build a higher-level DSL that captures the similarity. For example, all Jenkins plugins are built and tested in the same way, so we might write a step named buildPlugin:

**`vars/buildPlugin.groovy`**

```
def call(Map config) {
    node {
        git url: "https://github.com/jenkinsci/${config.name}-plugin.git"
        sh 'mvn install'
        mail to: '...', subject: "${config.name} plugin build", body: '...'
    }
}
```

Assuming the script has either been loaded as a **Global Shared Library** or as a F**older-level Shared Library** the resulting Jenkinsfile will be dramatically simpler:

```
Jenkinsfile (Scripted Pipeline)
buildPlugin name: 'git'
```

There is also a “builder pattern” trick using Groovy’s `Closure.DELEGATE_FIRST`, which permits `Jenkinsfile` to look slightly more like a configuration file than a program, but this is more complex and error-prone and is not recommended.


## Using third-party libraries

It is possible to use third-party Java libraries, typically found in `Maven Central`, from trusted library code using the `@Grab` annotation. Refer to the Grape documentation for details, but simply put:

```
@Grab('org.apache.commons:commons-math3:3.4.1')
import org.apache.commons.math3.primes.Primes
void parallelize(int count) {
  if (!Primes.isPrime(count)) {
    error "${count} was not prime"
  }
  // …
}
```

Third-party libraries are cached by default in `~/.groovy/grapes/` on the Jenkins master.

## Loading resources

External libraries may load adjunct files from a `resources/` directory using the `libraryResource` step. The argument is a relative pathname, akin to Java resource loading:

```
def request = libraryResource 'com/mycorp/pipeline/somelib/request.json'
```
The file is loaded as a string, suitable for passing to certain APIs or saving to a workspace using `writeFile`.

It is advisable to use an unique package structure so you do not accidentally conflict with another library.


## Defining Declarative Pipelines

Starting with Declarative 1.2, released in late September, 2017, you can define Declarative Pipelines in your shared libraries as well. Here’s an example, which will execute a different Declarative Pipeline depending on whether the build number is odd or even:

**`vars/evenOrOdd.groovy`**

```
def call(int buildNumber) {
  if (buildNumber % 2 == 0) {
    pipeline {
      agent any
      stages {
        stage('Even Stage') {
          steps {
            echo "The build number is even"
          }
        }
      }
    }
  } else {
    pipeline {
      agent any
      stages {
        stage('Odd Stage') {
          steps {
            echo "The build number is odd"
          }
        }
      }
    }
  }
}
```

**`Jenkinsfile`**

```
// Jenkinsfile
@Library('my-shared-library') _

evenOrOdd(currentBuild.getNumber())
```





