variable "environment" {
  description = "Environment resources belong to"
}

variable "aws_profile" {
  description = "AWS Profile to use"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "vpc_name" {
  description = "Vpc name"
}

variable "subnets" {
  description = "subnets"
  type        = list(string)
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "cluster_name" {
  description = "Cluster name"
}

variable "k8s_service_account_namespace" {
  description = ""
}

variable "k8s_service_account_name" {
  description = ""
}

variable "target_group_port" {
  description = ""
}

