# Stretch sketch. Mirrors Dev wiring with different CIDR + names.
# Not hooked to CI apply yet on purpose.

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      jb_project = "jobbser"
      jb_env     = "check"
      managed_by = "terraform"
      billed_to  = "platform"
    }
  }
}

locals {
  name_prefix = "jb-check"
  tags = {
    jb_project = "jobbser"
    jb_env     = "check"
    managed_by = "terraform"
    billed_to  = "platform"
  }
}

variable "acm_cert_arn" {
  type    = string
  default = "arn:aws:acm:eu-west-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"
}

variable "api_image_uri" {
  type    = string
  default = "000000000000.dkr.ecr.eu-west-1.amazonaws.com/jobbser-api:check-placeholder"
}

module "edge" {
  source       = "../../modules/vpc-alb"
  name_prefix  = local.name_prefix
  vpc_cidr     = "10.50.0.0/16"
  az_names     = ["eu-west-1a", "eu-west-1b"]
  public_cidrs = ["10.50.0.0/24", "10.50.1.0/24"]
  private_cidrs = ["10.50.10.0/24", "10.50.11.0/24"]
  create_nat   = true
  acm_cert_arn = var.acm_cert_arn
  tags         = local.tags
}

module "runtime_secret" {
  source      = "../../modules/api-runtime-secret"
  name_prefix = local.name_prefix
  tags        = local.tags
}

resource "aws_security_group" "api_tasks" {
  name        = "${local.name_prefix}-api-tasks"
  description = "Jobbser-Api tasks (check)"
  vpc_id      = module.edge.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [module.edge.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { jb_component = "api" })
}

module "mysql" {
  source         = "../../modules/jobbser-mysql"
  name_prefix    = local.name_prefix
  vpc_id         = module.edge.vpc_id
  subnet_ids     = module.edge.private_subnet_ids
  client_sg_ids  = [aws_security_group.api_tasks.id]
  secret_arn     = module.runtime_secret.arn
  instance_class = "db.t4g.micro"
  backup_days    = 7
  allow_destroy  = true
  tags           = local.tags
}

module "api" {
  source             = "../../modules/jobbser-api"
  name_prefix        = local.name_prefix
  vpc_id             = module.edge.vpc_id
  subnet_ids         = module.edge.private_subnet_ids
  task_sg_id         = aws_security_group.api_tasks.id
  https_listener_arn = module.edge.https_listener_arn
  api_image_uri      = var.api_image_uri
  task_count         = 1
  runtime_secret_arn = module.runtime_secret.arn
  log_days           = 14
  aspnet_env         = "Staging"
  tags               = local.tags
}

module "uploads" {
  source      = "../../modules/upload-bucket"
  name_prefix = local.name_prefix
  tags        = local.tags
}
