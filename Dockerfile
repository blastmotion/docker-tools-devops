#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM node:lts

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Verify git and needed tools are installed
RUN apt-get install -y git procps unzip python3 python3-pip

# Remove outdated yarn from /opt and install via package 
# so it can be easily updated via apt-get upgrade yarn
RUN rm -rf /opt/yarn-* \
    && rm -f /usr/local/bin/yarn \
    && rm -f /usr/local/bin/yarnpkg \
    && apt-get install -y curl apt-transport-https lsb-release \
    && curl -sS https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get -y install --no-install-recommends yarn

# Install AWS CLI
RUN pip3 install awscli --upgrade

# Install AWS Vault
ADD https://github.com/99designs/aws-vault/releases/download/v4.6.1/aws-vault-linux-amd64 /usr/local/bin/aws-vault
RUN chmod +x /usr/local/bin/aws-vault

# Install Terraform CLI
ADD https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_linux_amd64.zip ./
RUN unzip terraform_0.12.3_linux_amd64.zip -d /usr/local/bin/
RUN rm -f terraform_0.12.3_linux_amd64.zip

# Install eslint, ampllify, apollo
RUN npm install -g eslint @aws-amplify/cli apollo-server graphql graphql-cli

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash