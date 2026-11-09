# Jobbser primary MySQL (inventory: RDS MySQL, small single-AZ in non-prod).
# Schema stays in app migrations. This module is just the box.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-mysql-subnets"
  subnet_ids = var.subnet_ids
  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-mysql-subnets"
    jb_component = "mysql"
  })
}

resource "aws_security_group" "mysql" {
  name        = "${var.name_prefix}-mysql"
  description = "MySQL only from Jobbser-Api tasks"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.client_sg_ids
    content {
      description     = "MySQL from API tasks"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-mysql-sg"
    jb_component = "mysql"
  })
}

data "aws_secretsmanager_secret_version" "master" {
  secret_id = var.secret_arn
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.master.secret_string)["db_password"]
}

resource "aws_db_instance" "mysql" {
  identifier     = "${var.name_prefix}-mysql"
  engine         = "mysql"
  engine_version = var.mysql_version
  instance_class = var.instance_class

  allocated_storage     = var.storage_gb
  max_allocated_storage = var.storage_gb * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.master_user
  password = local.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_days
  skip_final_snapshot     = var.allow_destroy
  deletion_protection     = !var.allow_destroy
  performance_insights_enabled = false

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-mysql"
    jb_component = "mysql"
  })
}
