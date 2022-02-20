module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.7.2"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnet_ids      = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

# Self managed not recommended as it's more work for us. Prefer eks_managed instead
# This still isn't working yet. Instances launch, but don't join cluster
  self_managed_node_groups = {
    one = {
      name          = "worker-group-1"

      platform      = "bottlerocket"
      #could use custom AIM here, otherwise gets latest
      #ami_id        = data.aws_ami.eks_default_bottlerocket.id
      instance_type = "t2.small"

      max_size      = 3
      desired_size  = 2
      vpc_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      
          }
        }        


#eks_managed_node_group_defaults = {
#    ami_type       = "AL2_x86_64"
#    disk_size      = 50
#    instance_types = ["t3.small", "t3.medium"]

    # We are using the IRSA created below for permissions
#    iam_role_attach_cni_policy = false
#  }

#  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
#    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
#      create_launch_template = false
#      launch_template_name   = ""

      # Remote access cannot be specified with a launch template
#      remote_access = {
#        ec2_ssh_key               = aws_key_pair.this.key_name
#        source_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#      }
#    }
#    }
}
