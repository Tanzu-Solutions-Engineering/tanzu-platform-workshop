# Platform Engineer Lab Prerequisites

## Workshop Owner pre-requisites
- vSphere 8.02c environment(s)
    - Workload Management enabled with AVI
    - Supervisor cluster v1.27.5+vmware.1-fips.1
    - ContentLibrary synced with TKrs 1.27.11 and 1.28.8 available
    - Compute capacity for 2x TKGS clusters with 1 CP node and 3 worker nodes with 4VCPU & 16GBRAM per VM per attendee
    - At least 8 VM IPs available for all those k8s nodes per attendee
    - At least 6 AVI VIPs available for those 2 clusters and 1 Space/App per attendee (1 VIP for CP, 2 VIP for ingress per cluster)
    - Supervisor Namespace created with Storage Policy and VM Classes associated to it
- AWS Route53 Zone
    - Domain registered/delegated to Route53 zone
- Tanzu Platform for Kubernetes Org + Group + Project
    - AWS Account, EKS Credential and GSLB Credential configured
    - AWS EKS Cluster
- Onboard all attendees on designated Tanzu Platform for k8s CSP org and project

## Workshop Attendee pre-requisites
- kubectl CLI v1.28.8 installed in workstation - [kubectl CLI install guide](https://v1-28.docs.kubernetes.io/releases/download/)
- tanzu CLI v1.3.0 installed in workstation - [tanzu CLI installation guide](https://docs.vmware.com/en/VMware-Tanzu-CLI/1.3/tanzu-cli/index.html)
- tanzu CLI plugins for platform engineer installaed - [tanzu CLI PE plugins installation guide](https://docs.vmware.com/en/VMware-Tanzu-Platform/services/create-manage-apps-tanzu-platform-k8s/getting-started-create-app-envmt.html#before-you-begin-0)
```
tanzu plugin install --group vmware-tanzu/platform-engineer
```
