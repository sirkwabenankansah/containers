FROM ubuntu:20.04

ENV TERRAFORM_VERSION=1.7.2
ENV PACKER_VERSION=1.8.5
ENV ANSIBLE_VERSION=5.9.0
ENV KUBECTL_VERSION=1.19
ENV ZARF_VERSION=0.13.0

RUN apt-get update && apt-get install -y \ 
    curl \
    unzip \
    wget \
    git \
    python3-pip \
    python3-setuptools

# Download and install Terraform
ARG TERRAFORM_VERSION=1.1.0
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Copy your Terraform configuration file into the image
COPY main.tf /data/main.tf

# Set the working directory
WORKDIR /data

# Initialize Terraform to install the AWS provider
# Note: This step is typically run with the project files, so it might not be ideal to include in a Dockerfile
RUN terraform init
RUN terraform plan
RUN terraform apply --auto-approve

# Install Packer  
RUN curl -fsSL https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -o packer.zip && \
    unzip packer.zip -d /usr/local/bin && \ 
    rm packer.zip

# Install Ansible
RUN pip3 install ansible==$ANSIBLE_VERSION

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Define Zarf version
# ARG ZARF_VERSION=0.13.0

# Install zarf
# RUN wget -O zarf.tar.gz https://github.com/lefthandedgoat/zarf/releases/download/v${ZARF_VERSION}/zarf_${ZARF_VERSION}_Linux_x86_64.tar.gz \
#    && tar -xzf zarf.tar.gz \
#    && mv zarf /usr/local/bin/ \
#    && rm zarf.tar.gz

CMD ["/bin/bash"]