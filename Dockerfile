FROM alpine:3.10

ENV HELM_VERSION 3.1.2
ENV KUBECTL_VERSION 1.16.6
ENV DOCTL_VERSION 1.41.0

WORKDIR /

# Enable SSL, helm plugins require git, helm-diff requires bash, curl
RUN apk --update add ca-certificates wget python curl tar openssh git bash

# Install kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

# Install Helm
ENV FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_URL https://get.helm.sh/${FILENAME}

RUN curl -o /tmp/$FILENAME ${HELM_URL} \
  && tar -zxvf /tmp/${FILENAME} -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp

# Plugin is downloaded to /tmp, which must exist
RUN mkdir /tmp
RUN helm plugin install https://github.com/chartmuseum/helm-push.git

RUN cd /usr/local/bin && \
  curl -sL https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz | tar -xz