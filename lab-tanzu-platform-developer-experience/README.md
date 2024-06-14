# Tanzu Platform Developer Experience

The workshop covers the developer experience of deploying applications to the Tanzu Platform

## Local development
Download the Educates CLI [(Instructions)](https://docs.educates.dev/getting-started/quick-start-guide#downloading-the-cli) 

```
export DOCKER_API_VERSION=1.41
educates create-cluster # educates delete-cluster

educates publish-workshop
educates deploy-workshop
educates browse-workshops
educates view-credentials
```

After **content changes**, just publish the workshop again. 
```
educates publish-workshop
```
Create a new workshop session to see the changes or run `update-workshop` in the workshop environment.


For **workshop definition changes** in the `resources/workshop.yam` file, you need to update the workshop definition in the Kubernetes cluster.
```
educates update-workshop
```
