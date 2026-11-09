# Dev stack wiring.
#
# Order:
#   1. edge (vpc-alb)
#   2. runtime secret
#   3. API task SG in this stack (so MySQL can allow it before the ECS module)
#   4. MySQL
#   5. Jobbser-Api service
#   6. uploads bucket + IAM glue
#
# SES / MsgHub: see ../../deferred/

module "edge" {
  source = "../../modules/vpc-alb"

  name_prefix  = local.name_prefix
  vpc_cidr     = var.vpc_cidr
  az_names     = var.az_names
  public_cidrs = var.public_cidrs
  private_cidrs = var.private_cidrs
  create_nat   = var.create_nat
  acm_cert_arn = var.acm_cert_arn
  tags         = local.base_tags
}

module "runtime_secret" {
  source = "../../modules/api-runtime-secret"

  name_prefix = local.name_prefix
  tags        = local.base_tags
}

# Security group lives in the stack on purpose.
# I want MySQL rules before the ECS service module exists.
resource "aws_security_group" "api_tasks" {
  name        = "${local.name_prefix}-api-tasks"
  description = "Jobbser-Api Fargate tasks"
  vpc_id      = module.edge.vpc_id

  ingress {
    description     = "ALB to API"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [module.edge.alb_sg_id]
  }

  egress {
    description = "RDS, S3, Secrets, Stripe, FCM, later SES"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, {
    Name         = "${local.name_prefix}-api-tasks"
    jb_component = "api"
  })
}

module "mysql" {
  source = "../../modules/jobbser-mysql"

  name_prefix    = local.name_prefix
  vpc_id         = module.edge.vpc_id
  subnet_ids     = module.edge.private_subnet_ids
  client_sg_ids  = [aws_security_group.api_tasks.id]
  secret_arn     = module.runtime_secret.arn
  instance_class = var.mysql_class
  multi_az       = false
  backup_days    = 3
  allow_destroy  = true
  tags           = local.base_tags
}

module "api" {
  source = "../../modules/jobbser-api"

  name_prefix         = local.name_prefix
  vpc_id              = module.edge.vpc_id
  subnet_ids          = module.edge.private_subnet_ids
  task_sg_id          = aws_security_group.api_tasks.id
  https_listener_arn  = module.edge.https_listener_arn
  api_image_uri       = var.api_image_uri
  app_port            = var.app_port
  task_count          = local.api_desired
  give_public_ip      = var.give_tasks_public_ip
  runtime_secret_arn  = module.runtime_secret.arn
  log_days            = 7
  aspnet_env          = "Development"
  tags                = local.base_tags
}

module "uploads" {
  source = "../../modules/upload-bucket"

  name_prefix   = local.name_prefix
  force_destroy = true
  tags          = local.base_tags
}

data "aws_iam_policy_document" "api_uploads" {
  statement {
    sid       = "ListUploads"
    actions   = ["s3:ListBucket"]
    resources = [module.uploads.bucket_arn]
  }
  statement {
    sid = "ObjectRW"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.uploads.bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "api_uploads" {
  name   = "${local.name_prefix}-api-uploads"
  role   = module.api.task_role_name
  policy = data.aws_iam_policy_document.api_uploads.json
}
