# One Secrets Manager secret for Jobbser-Api runtime config.
# Inventory lists DB, JWT, Stripe, Firebase, hub URL in here.
# I create the shell in Terraform. Humans put real values in later.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  secret_name = var.secret_path != "" ? var.secret_path : "${var.name_prefix}/jobbser-api/runtime"
}

resource "aws_secretsmanager_secret" "api" {
  name                    = local.secret_name
  description             = "Jobbser-Api runtime bundle (${var.name_prefix})"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name         = local.secret_name
    jb_component = "api"
  })
}

resource "aws_secretsmanager_secret_version" "api" {
  secret_id     = aws_secretsmanager_secret.api.id
  secret_string = var.placeholder_json

  lifecycle {
    ignore_changes = [secret_string]
  }
}
