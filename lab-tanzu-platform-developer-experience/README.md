# Tanzu Platform Developer Experience

The workshop covers the developer experience of deploying applications to the Tanzu Platform

## Workshop installation
Adjust the configuration in [lab-tanzu-platform-developer-experience/resources/workshop-values.yaml](lab-tanzu-platform-developer-experience/resources/workshop-values.yaml) for your Tanzu Platform environment.

For the optional automated TP for Kubernetes Space creation per workshop session, you have to provide an API token with "Organization Member" and "Tanzu Platform for Kubernetes Developer" roles

```
(cd lab-tanzu-platform-developer-experience/resources/ && ytt -f workshop-template.yaml -f workshop-values.yaml | kubectl apply -f -)
```