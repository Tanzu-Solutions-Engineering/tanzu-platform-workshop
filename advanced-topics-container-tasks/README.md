# Creating custom container tasks

Container tasks can be used to enhance the build process. There are many scenarios where additonal configuration may be needed in the output of the build process. Container Tasks provided a re-usable scalable way of adding steps to the buidl process. This part of the workshop will walk through creatng a simple container task and adding it to the platform. 



## Objective

Create a simple container task that adds an http route to the app being deployed.


## Create the task

1. create a folder for this project

```bash
mkdir custom-container-task
```

2. create the base httproxy file. This is used later in the task to generate the final `httproute`

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: placeholder
  annotations:
    healthcheck.gslb.tanzu.vmware.com/service: placeholder
    healthcheck.gslb.tanzu.vmware.com/path: /
    healthcheck.gslb.tanzu.vmware.com/port: "80"
spec:
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: default-gateway
    sectionName: https-placeholder
  rules:
  - backendRefs:
    - group: ""
      kind: Service
      name: placeholder
      port: 80
      weight: 1
    matches:
    - path:
        type: PathPrefix
        value: /
```


3. create a `task.py` file. This will contain all of our task code. This can be written in any language, we chose python for this example becuase it is easy to parse yaml and test locally.

```python
#!/usr/bin/env python

import yaml
import os

# this uses a built in env variable to get the root directory of the build
workspaceDir = os.environ.get('TANZU_BUILD_WORKSPACE_DIR')

# the output of the build process will land in the output dir in the workspace root. We are loading the 
# containerapp to get values from it.
print("creating httproute")
with open(workspaceDir + '/output/containerapp.yml', 'r') as file:
    containerapp = yaml.safe_load(file)

# load in the sample httproute as a base
with open(workspaceDir + '/httproute.yml', 'r') as file:
    httproute = yaml.safe_load(file)

# update fields in the sample httproute with user provided content in the containerapp
httproute["metadata"]["name"] = containerapp["metadata"]["name"] + "-http-route"
httproute["metadata"]["annotations"]["healthcheck.gslb.tanzu.vmware.com/service"] = containerapp["metadata"]["name"]
httproute["metadata"]["annotations"]["healthcheck.gslb.tanzu.vmware.com/port"] = "443"

httproute["spec"]["parentRefs"][0]["sectionName"] = "https-"+containerapp["metadata"]["name"]
httproute["spec"]["rules"][0]["backendRefs"][0]["name"] = containerapp["metadata"]["name"]
httproute["spec"]["rules"][0]["backendRefs"][0]["port"] = containerapp["spec"]["ports"][0]["port"]

# write the file to the output directory
with open(workspaceDir + '/output/httproute.yml', 'w') as outfile:
    yaml.dump(httproute, outfile, default_flow_style=False)
```

4. create `requirements.txt` to load python dependencies

```
pyyaml
```

5. create the `Procfile` for buildpacks.

```yaml
web: python task.py
```

6. build and publish the container using tanzu build tooling

```bash
tanzu app init httproute-task --build-path . --build-type buildpacks
```

7. setup your build to use `ghcr.io`. you will also need to [login](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry) to this registry prior to pushing the image. 

```bash
tanzu build config --containerapp-registry ghcr.io/{contact.team}/{name}
```

8. edit the generated containerapp and add the `contact.team` that is used for our container registry path. 

```yaml
spec:
  contact:
    team: warroyo # this should be your github org name
```

9. build the image and push it to the registry

```bash
tanzu build -r container-image
```

## Create the custom containerappbuildplan to add the new task

We need to create a new build plan in order to use the task and then set the default build plan to be our custom one. this is what makes the task execute when running a build for apps.


1. Create a custom `containerAppBuildPlan`. We can do this by getting the existing one and modifying it.

```bash
tanzu project use <your project>

k get containerappbuildplans  simple.tanzu.vmware.com -o yaml > custom-bp.yml
```

modify the output yaml and change the name to `custom-build-plan` 

add the following to the `runtimes["kubernetes-carvel-package"].steps` section

```yaml
  - name: add-route
    containerTask:
      image: ghcr.io/<your org>/httproute-task
```

apply this back into the platform

```bash
k apply -f custom-bp.yml
```

1. set the build plan source 

```bash

tanzu build config --build-plan-source custom-build-plan
```

3. change into a directory with your app you want to deploy and deploy or build your app.Check the output for the httproute.

```bash
tanzu space use <myspace>
tanzu deploy
```