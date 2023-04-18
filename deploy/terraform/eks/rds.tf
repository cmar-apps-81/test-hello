module "postgresql-main_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 3.17"
  name        = "postgresql-main_sg"
  description = "Security group for main PostgreSQL"
  vpc_id      = data.aws_vpc.selected.id

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "172.29.0.0/19"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "aws_db_instance" "dbpostgresql_main-prd" {
  identifier = "dbpostgresql-main"

  username = data.sops_file.secrets.data["main_rds_username"]
  password = data.sops_file.secrets.data["main_rds_password"]

  db_subnet_group_name   = var.vpc_name
  vpc_security_group_ids = [module.postgresql-main_sg.this_security_group_id]

  engine                      = "postgres"
  engine_version              = "14.4"
  allow_major_version_upgrade = "false"
  auto_minor_version_upgrade  = "true"

  instance_class        = "db.t3.medium"
  storage_type          = "gp2"
  allocated_storage     = 50
  max_allocated_storage = 100
  deletion_protection   = "true"
  storage_encrypted     = "true"

  multi_az = "true"

  backup_retention_period = 7
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

