# Overview: This repo is for setting up AWS EKS demo cluster using Terraform base modules and helm

### !! Note :
#### 1. In this EKS Setup Control Plane is managed by AWS and Worker Nodes managed by User.
#### 2. VPC and Subnets are created automatically as part of this implementation.
#### 3.Make sure to install following cli tools upfront.
```Cancel changes
kubectl
terraform
helm
```

## EKS Cluster Creation

### 1. Make sure to update `terraform/local.tf` values as per your environment, Below are few important items to be updated.

Update the user mapping in `helm/aws-auth/values.yaml`
```
configmap:
  enabled: true
  name: aws-auth
data:
  mapAccounts: |
    - "<aws-account-no>"
  mapRoles: |
    - "groups":
      - "system:bootstrappers"
      - "system:nodes"
      "rolearn": "arn:aws:iam::<aws-account-no>:role/<aws-iam-role>"
      "username": "system:node:{{EC2PrivateDNSName}}"
  mapUsers: |
    - "groups":
      - "system:masters"
      "userarn": "arn:aws:iam::<aws-account-no>:user/<iam-user1>"
      "username": "<iam-user1>"
    - "groups":
      - "system:masters"
      "userarn": "arn:aws:iam::<aws-account-no>:user/<iam-user-2>"
      "username": "<iam-user-2>"
```

### 2. Make sure to update `terraform/backend.tf` values as per your environment

### 3. Run `terraform init` as it will create a new backend

### 4. Run `terraform plan` to see the changes

### 5. Run `terraform apply` to apply the changes

### 6. Once the EKS cluster is created, run below command to create kubeconfig file
```
aws eks update-kubeconfig --name <eks-cluster-name> --kubeconfig ~/.kube/config --region <aws-region>
```
### 7. Test the EKS cluster access by running below command
```
kubectl get namespaces
```

## Join EKS Worker Nodes to EKS Cluster
### 1. Run below commands to join worker nodes to EKS cluster
```
cd helm/
helm install -f values.yaml aws-auth ./aws-auth
```
### 2. Run below command to see the worker nodes joined to EKS cluster
```
kubectl get nodes
```
