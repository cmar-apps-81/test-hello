resource "aws_eip" "nat" {
  count = 1
  vpc   = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Name        = "${var.vpc_name}-eip-${count.index}"
  }
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "172.29.0.0/19"

  azs              = var.subnets
  public_subnets   = ["172.29.0.0/22", "172.29.4.0/22", "172.29.8.0/22"]
  private_subnets  = ["172.29.12.0/22", "172.29.16.0/22", "172.29.20.0/22"]
  database_subnets = ["172.29.24.0/23", "172.29.26.0/23", "172.29.28.0/23"]


  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  reuse_nat_ips        = true
  external_nat_ip_ids  = aws_eip.nat.*.id

  tags = {
    Terraform                                   = "true"
    Environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    KubernetesCluster                           = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
