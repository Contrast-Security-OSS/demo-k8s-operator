

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${local.cluster_name}-eks"
  cluster_version = "1.25"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane_contrast = {
      description                   = "Allow contrast_agent_operator readycheck communication from Cluster API to node pods on tcp/5001."
      protocol                      = "tcp"
      from_port                     = 5001
      to_port                       = 5001
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }
  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 3

      labels = {
        role = "general"
      }

      instance_types = ["t3.medium"]
    }
  }

    manage_aws_auth_configmap = true

  # TODO: Need to update this to use a built-in role
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_iam_role_name}"
      username = "AWS_Console_User_Access_Role"
      groups = [
        "system:masters"
      ]
    }
  ]

  tags = {
    Environment   = "${local.cluster_name}"
    SalesEngineer = "${var.initials}"
  }
}

