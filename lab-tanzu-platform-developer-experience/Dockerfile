FROM ghcr.io/vmware-tanzu-labs/educates-base-environment

USER root

# Tanzu CLI
RUN echo $' \n\
[tanzu-cli] \n\
name=Tanzu CLI \n\
baseurl=https://storage.googleapis.com/tanzu-cli-installer-packages/rpm/tanzu-cli \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://storage.googleapis.com/tanzu-cli-installer-packages/keys/TANZU-PACKAGING-GPG-RSA-KEY.gpg ' >> /etc/yum.repos.d/tanzu-cli.repo


RUN yum install -y tanzu-cli
RUN yes | tanzu plugin install --group vmware-tanzucli/essentials
RUN yes | tanzu plugin install --group vmware-tanzu/platform-engineer

COPY --chown=1001:0 . /home/eduk8s/

RUN fix-permissions /home/eduk8s

USER 1001