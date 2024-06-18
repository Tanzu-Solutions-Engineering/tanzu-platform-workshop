# Gitops for the platform infra components

This advanced topic covers how to use the tanzu cli and a git repo to declaratively deploy the infra related components for the platform. This example does not cover running the cli contiuously to enable the typical gitops reconcilitation behavior but it could be easily extended to do that.

components managed in this git repo:

* capabilties
* profiles
* availability targets
* spaces



## Repo structure

 ```bash
workshop01 # the project name
├── clustergroups
│   └── dev-cg01 # cluster group name
│       └── pkgi.yml # packages to install in the cluster group
├── custom-networking-warroyo.yml # custom profile deifinition
├── dev-avt.yml # availability target deifintion
├── space-dev-team1.yml # space definition
├── spaces # contains any spaces and thier contents
│   └── dev-team1
└── tanzu.yml # defines the project id
```



## Deploying

the cli will know how to switch into the right context to deploy what it needs.

```bash
cd workshop01
tanzu deploy
```