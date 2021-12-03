# Make sure to update the values mentioned in the anchor below
locals {
  #general config

  aws-profile   = "default"
  aws-region    = "<aws-region>"
  environment   = "<environment>"
  account_id    = "<aws-account-no>"
  stackname     = "<eks>"
  subsystem_val = "<demo1>"

  #vpc related config values
  vpc_name                = "${local.stackname}-${local.subsystem_val}-vpc"
  vpc_cidr                = "10.0.0.0/16"
  availability_zones      = ["<aws-region>-1a","<aws-region>-1b","<aws-region>-1c"]
  private_subnets         = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
  kubernetes_cluster_name = "${local.stackname}-${local.environment}-${local.subsystem_val}-ekscluster"

  #Userdata for nodes
  node-userdata = <<USERDATA
  #!/bin/bash
  set -o xtrace
  # These are used to install SSM Agent to SSH into the EKS nodes.
  sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  systemctl enable amazon-ssm-agent
  systemctl restart amazon-ssm-agent
  /etc/eks/bootstrap.sh --apiserver-endpoint '${module.eks_master.eks_master_endpoint}' --b64-cluster-ca '${module.eks_master.cluster_certificate_authority_data}' '${local.kubernetes_cluster_name}'
  # Retrieve the necessary packages for `mount` to work properly with NFSv4.1
  sudo yum update -y
  sudo yum install -y amazon-efs-utils nfs-utils nfs-utils-lib
  # after the eks bootstrap and necessary packages installation - restart kubelet
  systemctl restart kubelet.service
  USERDATA


  #Worker node launch config
  instance_type               = "t3a.medium"
  name_prefix                 = "${local.stackname}-${local.environment}-${local.subsystem_val}-eksworker"
  # name                        = "${local.stackname}-${local.environment}-${local.subsystem_val}-eksworker"
  associate_public_ip_address = true
  image_id                    = "ami-00650807756050152" # change the AMI ID as per your requirement
  # image_id                    = data.aws_ami.eks-worker.id
  user_data_base64            = base64encode(local.node-userdata)
  cluster_version             = "1.18" # change the version to the latest version

  #Worker node asg config
  ec2_key_pair     = "<ec2-keypair-name>"
  desired_capacity = 4
  max_size         = 6
  min_size         = 2
  asg_name         = "${local.stackname}-${local.environment}-${local.subsystem_val}-eksworker"
  workstation_cidr = ["<Local Machine IP>"] # Put your local machine IP here

}

## data lookups

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${module.eks_master.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}