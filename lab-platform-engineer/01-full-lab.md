# Platform Engineer Hands-on Lab

## Share Environment details and confirm pre-requisites
The workshop owner should share with the attendees:
- Designated Tanzu Platform for k8s URL, Org and Project
- vSphere environment url, credentials and Supervisor name used to register in Tanzu Platform

All workshop participants to verify they are all set with steps in [Workshop Attendee pre-requisites](../lab-platform-engineer/00-prerequisites.md#workshop-attendee-pre-requisites)


## Register TKGS Supervisor in designated Tanzu Platform for k8s project
Official pubic documentation pending

[vSphere with Tanzu documentation to register Supervisor in TMC](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-installation-configuration/GUID-ED4417DC-592C-454A-8292-97F93BD76957.html#install-the-tanzu-mission-control-agent-on-the-supervisor-1)

Process:
- Step 1: Access the GUI: `Setup & Configuration > Kubernetes Management > TKG Registrations > Register TKG Instance` to get the registration url
- Step 2: Go to VCenter: `workload management > Supervisors > Configure > Tanzu Mission Control Registration`, and add that registration url.

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
Remove Crossplane capability from the Cluster Group: if not choosing it the bitnami package will fail:
- When that capability deployment fails, space scheduling will stay in WARNING
- Once you add crossplane, bitnami package will reconcyle.
- After that Space should go ready after .... 1 or 2 minutes

## Create a TKGS cluster in your Cluster Group
Official pubic documentation pending

Access the GUI: `Infrastructure > Kuberentes Clusters > Clusters > Add Cluster > Create Tanzu Kubernetes Grid Cluster`:
- Step 1: Select the management cluster and provisioner
    - The management cluster is the Supervisor cluster that the workshop owner provided you.
    - Provisioner: click to show a drop down menu and choose the name of the Supervisor Namespace that the workshop owner provided you.
- Step 2: Name and assign
    - Cluster name: pick a name.
    - Cluster Group: click to show a drop down menu and choose the Cluster Group you created earlier.
    - Cluster class: click to show a drop down menu and choose `tanzukubernetesclusterclass`.
    - Labels: DO NOT SKIP!
        - Choose a couple of labels to have options later to target your clusters. Example: `test: true` and `vsphere: 8.0.2c`
- Step 3: Configure network and storage settings
- Step 4: Control plane
- Step 5: Configure default volumnes
- Step 6: Conigure node pool
- Step 7: Additional cluster configuration

#### Understand how the TKGS cluster is onboarded to the Platform

## Create Availability Targets

## Configure a GSLB via custom Profile

## Create a Space for developers to deploy apps on TKGS