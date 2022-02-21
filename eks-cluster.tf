module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.7.2"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  #allow cluster API access both public and private. This allows to run kubectl without a vpn. Not good for production
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }
  
 cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]
  subnet_ids      = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    # We are using the IRSA created below for permissions
    # This is a better practice as well so that the nodes do not have the permission,
    # only the VPC CNI addon will have the permission
    iam_role_attach_cni_policy = false
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.small","t3.medium"]
    #Addtional security group that allows us to connect to the nodes
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    default = {
      create_launch_template = false
      launch_template_name = ""
    }
#   compute = {
#     instance_types = ["t2.small","t2.medium"]
#   }
    
#    graviton_bottlerocket = {
#      ami_type = "BOTTLEROCKET_ARM_64"
#      instance_types = ["t4g.small", "t4g.medium"]
#    }
  }

  tags = local.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

    tags = local.tags
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "karpenter_controller"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_ids        = [module.eks.cluster_id]
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["default"].iam_role_arn
  ]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

   tags = local.tags
}
