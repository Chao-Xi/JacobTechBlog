![Alt Image Text](images/headline17.jpg "Headline image")

# Docker Practice#1: Run jenkins with docker

**Official Jenkins Docker image:** [https://github.com/jenkinsci/docker](https://github.com/jenkinsci/docker)

## 1.Dockerfile

```
#jenkins official dockerfile
#https://github.com/jenkinsci/docker

FROM jenkins/jenkins:2.89.4
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
```

## 2.Build the image from a Dockerfile with tags

**Inside the local workdir with Dockerfile**

```
sudo docker build -t 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:${current_git_branch}.${git_env.GIT_COMMIT}

689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:release_aws-cd-jenkins.c069b991099d784b20a3522269cca33871eea445
```

## 3.Tag an image referenced by Name and Tag

```
docker tag 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:${current_git_branch}.${git_env.GIT_COMMIT} 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:${image_build_tag}

docker tag 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:release_aws-cd-jenkins.c069b991099d784b20a3522269cca33871eea445 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:jenkins-jenkins_image_builder_branches-release_aws-cd-jenkins-9
```

## 4.Push an image or a repository to a ECR

* login into aws ecr

```
/usr/local/bin/aws ecr get-login --region us-east-1 --no-include-email|bash;
```

* push docker image with image name

```
docker push 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins;
```

## 5. Update jenkins plugins and run jenkins as container

* Update plugin.txt

* Check current running jenkins container and stop it and remove it 

```
docker ps -a                      #list current running container
docker stop container_id          #stop the running container 
docker rm -v old_container_id     #remove old and deprecated containerid
```

* Login into aws ecr

```
/home/ubuntu/.local/bin/aws ecr get-login --region us-east-1 --no-include-email|bash
```


* Run the new image with ports and add stash host and crowd host and JAVA env

```
docker run -d -p 8080:8080 -p 50000:50000 --add-host=stash.bbpd.io:10.103.59.210 --add-host=crowd-291.bbpd.io:10.103.60.153 --env=JAVA_OPTS=-Djenkins.install.runSetupWizard=false -v /var/lib/jenkins:/var/jenkins_home 689783647424.dkr.ecr.us-east-1.amazonaws.com/jenkins:release_aws-cd-jenkins.31065cbe3ba6059d9af3d20b921dbc2aeaef3af0
```

```
-d  "--detach"  Run container in background and print container ID
-p  port
--add-host  Add a custom host-to-IP mapping (host:ip)
-v  --volume=[host-src:]container-dest[:<options>]
You might need to customize the JVM running Jenkins, typically to pass system properties or 
tweak heap memory settings. Use JAVA_OPTS environment variable for this purpose :
--env=JAVA_OPTS=-Djenkins.install.runSetupWizard=false
```

## 6.New jenkins run successfully

```
check plugin count
import jenkins.model.*
import groovy.json.JsonSlurper
import groovy.json.JsonOutput
def plugin_list = [:]
def instance = Jenkins.getInstance()
println ('Detail')
println ('-----------------------------------------------------')
println ('-----------------------------------------------------')

instance.pluginManager.plugins.each { plugin -> 
    println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}");
    plugin_list["${plugin.getShortName()}"]  = "${plugin.getVersion()}"
}
println (plugin_list)
println ('-----------------------------------------------------')
println ('-----------------------------------------------------')
println ('Yaml')
println ('-----------------------------------------------------')
println ('-----------------------------------------------------')

plugin_list.each{name, version -> 
  println ("$name : \"$version\"")
}
println ('-----------------------------------------------------')
println ('-----------------------------------------------------')
println ('Json')
println ('-----------------------------------------------------')
println ('-----------------------------------------------------')
println JsonOutput.prettyPrint(JsonOutput.toJson(plugin_list))

```
