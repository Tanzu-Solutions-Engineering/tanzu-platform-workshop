curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.20.0-beta.9/vcluster-linux-amd64" && chmod +x vcluster && mv vcluster $HOME/bin/
cat <<EOF >> vcluster.yaml
controlPlane:
  distro:
    eks: 
      enabled: true 
  proxy:
    extraSANs: 
    - vcluster-$SESSION_NAMESPACE.$INGRESS_DOMAIN
sync:
  fromHost:
    nodes:
      enabled: true
      selector:
        all: true
EOF

vcluster create vcluster-$SESSION_NAME --update-current=false -n $SESSION_NAMESPACE -f vcluster.yaml

