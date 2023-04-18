aws_region  = "eu-west-1"
aws_profile = "cmar"
environment = "svc"
vpc_name    = "vpc-svc"
subnets     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

cluster_name      = "k8s-cmar"
k8s_service_account_namespace = "kube-system"
k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler"

target_group_port = 31647

