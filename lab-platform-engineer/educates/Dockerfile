FROM ghcr.io/vmware-tanzu-labs/educates-base-environment

USER root

# Tanzu CLI
RUN echo $' \n\
[tanzu-cli] \n\
name=Tanzu CLI \n\
baseurl=https://storage.googleapis.com/tanzu-cli-os-packages/rpm/tanzu-cli \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub ' >> /etc/yum.repos.d/tanzu-cli.repo
RUN yum install -y tanzu-cli
RUN yes | tanzu plugin install --group vmware-tanzucli/essentials
RUN yes | tanzu plugin install --group vmware-tanzu/platform-engineer

# Install krew
RUN \
( \
  set -x; cd "$(mktemp -d)" && \
  OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
  KREW="krew-${OS}_${ARCH}" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
  tar zxvf "${KREW}.tar.gz" && \
  ./"${KREW}" install krew \
)
RUN echo "export PATH=\"${KREW_ROOT:-$HOME/.krew}/bin:$PATH\"" >> ${HOME}/.bashrc
ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
RUN kubectl krew install ctx
RUN kubectl krew install ns
RUN kubectl krew install konfig
RUN kubectl krew install eksporter
RUN chmod 775 -R $HOME/.krew

# vcluster CLI
RUN curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.20.0-beta.9/vcluster-linux-amd64" && chmod +x vcluster && mkdir -p $HOME/bin/ && mv vcluster $HOME/bin/


# Utilities
RUN yum install ruby -y

COPY --chown=1001:0 . /home/eduk8s/

RUN mv /home/eduk8s/workshop /opt/workshop

RUN fix-permissions /home/eduk8s

USER 1001