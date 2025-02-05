# Tanzu Platform Developer Experience

The workshop covers the developer experience of deploying applications to the Tanzu Platform

## Workshop installation
Adjust the configuration in [lab-tanzu-platform-developer-experience/resources/workshop-values.yaml](lab-tanzu-platform-developer-experience/resources/workshop-values.yaml) for your Tanzu Platform environment.

The workshop requires a PostgreSQL database reachable from the TP SaaS workload cluster. The host and password can be configured via "db_password" and "db_host". The easiest way to set it up is via an PostgreSQLInstance in the workload cluster. 
```
(cd lab-tanzu-platform-developer-experience/resources/ && ytt -f workshop-template.yaml -f workshop-values.yaml | kubectl apply -f -)
```