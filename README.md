# Learn Terraform - Provision an EKS Cluster

This will build a full kubernetes cluster with all required resources. It is designed to be built in an empty lab environment and destroyed when not in use.  

This repo is based on the Learn Terraform EKS Cluster a companion repo to the [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster), containing
Terraform configuration files to provision an EKS cluster on AWS.

Prerequisites: must have the following installed:  
awscli kubectl helm terraform  

Configure your AWS account credentials with 
```
aws configure
```

Run   
```
terraform apply  
```
This takes about 15 minutes  
After running terraform apply, configure your kubeconfig with  
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
You can now use kubectl commands to try stuff out.  
This costs around $2 for 8 hours use assuming you don't add more nodes or scale out.
When you are finished messing around, destroy everything and stop costs by running
```
terraform destroy
```
The destroy should only take about 5 minutes  
  
Install argo-cd with helm https://www.arthurkoziel.com/setting-up-argocd-with-helm/
```
helm install argo-cd charts/argo-cd/
```
Ignore the warnings
