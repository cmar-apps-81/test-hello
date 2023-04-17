resource "aws_security_group" "nodes_security_group" {
  name_prefix = "nodes-${var.cluster_name}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 30999
    to_port     = 30999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 31657
    to_port     = 31657
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 30989
    to_port         = 30989
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-svc-cmar-com.id]
  }

  ingress {
    from_port       = 31647
    to_port         = 31647
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-svc-cmar-com.id]
  }

}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.5.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.20"
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  worker_ami_name_filter          = "amazon-eks-node-1.20-v20210826"
  write_kubeconfig                = false
  #cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa = true

  worker_groups_launch_template = [
    {
      name                                     = "core-worker-group"
      override_instance_types                  = ["t3.medium", "t3a.medium"]
      spot_allocation_strategy                 = "lowest-price"
      root_encrypted                           = true
      root_volume_size                         = 50
      on_demand_base_capacity                  = "1"
      on_demand_percentage_above_base_capacity = "0"
      asg_min_size                             = 1
      asg_max_size                             = 12
      subnets                                  = tolist([module.vpc.private_subnets[0]])
      additional_userdata                      = file("${path.module}/userdata.sh")
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=mixed"
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
      default_cooldown          = 60
      health_check_grace_period = 60
      key_name                  = aws_key_pair.cmar-terraform.key_name
      target_group_arns         = [aws_alb_target_group.alb-svc-cmar-com_http.arn, aws_alb_target_group.alb-svc-cmar-com_https.arn]
      bootstrap_extra_args      = "--use-max-pods false"
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.nodes_security_group.id]

  map_users = var.map_users
  map_roles = var.map_roles

  tags = {
    Environment = var.environment
  }

}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
