# Instantitate-k8s-cluster-on-AWS-EC2

This repository contains files necessary to deploy a k8s cluster on AWS EC2 instances with one or more worker nodes.

It consists of the following shell scripts:

- Master node installation (master.sh) 
- Worker node installation (worker.sh)
- FluxCD installation (Flux CD installation.sh)

Prerequisites are:

1. Having an AWS account - for this you can follow this guideline -> https://www.google.com/search?q=create+free+aws+account+tutorial&oq=create+free+aws+account+tutorial&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQIRigATIHCAIQIRigATIHCAMQIRigAdIBCDU4NzlqMGo3qAIAsAIA&sourceid=chrome&ie=UTF-8#fpstate=ive&vld=cid:1c257179,vid:lIdh92JmWtg,st:15
   
2. Provisioned EC2 instances- for this you can follow my guideline using Terraform, for example -> https://github.com/dtunguz/Provision-EC2-AWS-resource-using-Terraform
