# Platform Engineer Lab Prerequisites

## Workshop Owner pre-requisites
- vSphere 8.02c environment
    - Workload Management enabled with AVI
    - Supervisor cluster v1.27.5+vmware.1-fips.1
    - ContentLibrary synced with TKrs 1.27.11 and 1.28.8 available
    - Compute capacity for 2x TKGS clusters with 1 CP node and 3 worker nodes with 4VCPU & 16GBRAM per VM per attendee
    - At least 8 VM IPs available for all those k8s nodes per attendee
    - At least 6 AVI VIPs available for those 2 clusters and 1 Space/App per attendee (1 VIP for CP, 2 VIP for ingress per cluster)
- AWS Route53 Zone
    - Domain registered/delegated to Route53 zone

## Workshop Attendee pre-requisites
