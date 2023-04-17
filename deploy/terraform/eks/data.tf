data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "selected" {
  name = "svc.cmar.io."
}
data "sops_file" "secrets" {
  source_file = "secrets.enc.json"
}
