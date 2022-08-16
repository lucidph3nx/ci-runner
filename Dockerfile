FROM circleci/runner:1.0.40761-ab081a3

USER root

ARG HELM_VERSION=3.2.4
ARG KUBECTL_VERSION=1.19.10
ARG TZ="Etc/UTC"

# Install Stuff
RUN apt update \
    && apt install -y \
      ca-certificates \
      curl \
      git \
      gnupg \
      jq \
      unzip \
      zip \
    && apt clean

# Install aws-cli v2
RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip -q awscliv2.zip \
    && aws/install \
    && aws --version \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples

# Install kubectl
RUN curl --silent --location --output /usr/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  && chmod +x /usr/bin/kubectl 

# Instal Helm as per https://helm.sh/docs/intro/install/
RUN set -x && curl --silent --location "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf /tmp/linux-amd64 \
    && chmod +x /usr/local/bin/helm \
    && helm version \
    && helm plugin install https://github.com/hypnoglow/helm-s3.git

USER circleci

WORKDIR /apps
