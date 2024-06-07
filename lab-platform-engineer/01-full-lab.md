# Platform Engineer Hands-on Lab

## Register TKGS Supervisor in designated Tanzu Platform for k8s project


## Prepare a Cluster Group with required capabilities

#### Create Cluster Group
[Official documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-create-run-cluster-group.html)
Access the GUI: `Infrastructure > Kubedrnetes Clusters > Create Cluster Group > Choose a name`

#### What are capabilities and what the Platform Engineer needs to do with them
[Official documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/concepts-about-spaces.html#capabilities--platform-apis-and-features-1)
(Insert image or link to diagram here)

#### Add capabilities to Cluster Group
[Official documentation](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/how-to-create-run-cluster-group.html#add-packages)
Access the GUI: `Application Spaces > Capabilities > Available`. We will add all capabilities one by one, keeping the defaults:
- Capabilities needed by the GSLB ingress Profile an its traits
	- Egress -> this will automatically pull ingress/multicloud-ingress and service mesh observability since the 3 of them are in the same Carvel package (tcs) today
	- Certificate Manager
	- Ingress
- Capabilities needed by the spring-dev profile: observability and carvel-package traits, and other capabilities
	- Observability
	- Service Mesh Observability (already added earlier as part of tcs)
	- Mutual TLS
	- Bitnami
	- Container Aapp.tanzu.vmware.com
	- Service Binding
	- Tanzu Service Binding
	- Gateway API
	- Spring Cloud Gateway.tanzu.vmware.com (can be skipped if not needed by app)
	- Crossplane (needed by bitnami)
- Additional capabilities
	- Registry Pull Only Credentials Installer
		- Rename to make it fit the char number limitation: reg-pull-only-creds
        - Add username, password and URL

#### (Optionl) Remove needed capability to test error scenario
Remove Crossplane capability from the Cluster Group: if not choosing it the bitnami package will fail
	- When that capability deployment fails, space scheduling will stay in WARNING
	- Once you add crossplane, bitnami package will reconcyle.
	- After that Space should go ready after .... 1 or 2 minutes

## Create a TKGS cluster in your Cluster Group
#### understand how it's onboarded to the Platform

## Create Availability Targets

## Configure a GSLB via custom Profile

## Create a Space for developers to deploy apps on TKGS