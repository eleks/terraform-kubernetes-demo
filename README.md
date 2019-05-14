# terraform-kubernetes-demo

the simple terraform module set to create kubernetes cluster. could be used for demo, dev, test environments

screencast: https://youtu.be/TVhM6UuwNdM

## Modules Overview

* `aws-demo-camunda` a demo module that uses others
* `aws-kub`  a module to create simple kubernetes cluster based on amazon virtual machines
* `aws-listener` exposes public port
* `bastion-sh` executes shell script from bastion
* `certificates` initializes demo certificates
* `kub-component-generic` the generic kub component deployment based on templates
* `kub-component-java-base` creates a kubernetes deployment and service for a java-based specific images
* `persistent-nfs` a simple deployment of artifacts through ssh/bastion 

## Camunda demo process

If you are going to execute camunda business process inside kubernetes check the following instructions: [./aws-demo-camunda/README.md](./aws-demo-camunda/README.md)

## Infrastructure Overview  
![architecture](assets/aws-demo-camunda.png)


**NOTE:** the following instruction works under linux and windows

### 0. Prerequisites 

**Create AWS iam user/group with the following permissions:**
1. AmazonEC2FullAccess
2. AmazonVPCFullAccess 
3. AmazonRoute53FullAccess
4. AmazonElasticFileSystemFullAccess
5. AmazonS3FullAccess

**Download terraform**
https://www.terraform.io/downloads.html

The terraform configs created for the version 0.11.13+

### 1. Generate your deployer key pair:  
go into the project root directory and generate the deployer-key and public ssh cert

or put into your home `~/.ssh` folder your key and public part for it

```shell
ssh-keygen -t rsa -f ~/.ssh/deployer-key
```

This key you could use to connect bastion server 

### 2. Define AWS credentials
Create file `1.auto.tfvars` in your root module (in our case `aws-demo-camunda`). 

The example: [./aws-demo-camunda/1.auto.tfvars.example](./aws-demo-camunda/1.auto.tfvars.example)

### 3. Create terraform workspace (dev/stage/prod/...)
go into the root module directory (example `aws-demo-camunda`) and run the following command
```shell
cd aws-demo-camunda
terraform workspace new bpm-demo
```

### 4. Initialize terraform for current configuration
The following command verifies your `*.tf` configuration and initializes your workspace according to it.
```shell
terraform init
```
### 5. Deploy your cluster
This command compares local configuration with current state and suggests changes to be applied. Type `yes` when asked.
```shell
terraform apply
```
  
### 6. Certificate  

We are using self-signed certificate  for Application LoadBalancer.
It is signed with custom CA certificate. So, to make server certificate valid for your brawser/mobile import the following certificate into the truststore:

[certificates/ca.docker.local.cer](certificates/ca.docker.local.cer)

details in [certificates/README.md](./certificates/README.md)

