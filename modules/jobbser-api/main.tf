# Jobbser-Api on ECS Fargate (inventory workload).
# MsgHub is a second service later. Same shape, different module call.
# Task SG is owned by the stack so MySQL can reference it first.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_region" "here" {}

resource "aws_ecs_cluster" "jb" {
  name = "${var.name_prefix}-ecs"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-ecs"
    jb_component = "api"
  })
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/jobbser/${var.name_prefix}/api"
  retention_in_days = var.log_days
  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-api-logs"
    jb_component = "api"
  })
}

data "aws_iam_policy_document" "assume_ecs" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "exec" {
  name               = "${var.name_prefix}-api-exec"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "exec_base" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "exec_secret" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.runtime_secret_arn]
  }
}

resource "aws_iam_role_policy" "exec_secret" {
  name   = "${var.name_prefix}-api-exec-secret"
  role   = aws_iam_role.exec.id
  policy = data.aws_iam_policy_document.exec_secret.json
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-api-task"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json
  tags               = var.tags
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.name_prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory_mib
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "jobbser-api"
      image     = var.api_image_uri
      essential = true
      portMappings = [{
        containerPort = var.app_port
        protocol      = "tcp"
      }]
      environment = [{
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.aspnet_env
      }]
      secrets = [{
        name      = "AppSecrets__Location"
        valueFrom = var.runtime_secret_arn
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = data.aws_region.here.name
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-api-td"
    jb_component = "api"
  })
}

resource "aws_lb_target_group" "api" {
  name        = "${var.name_prefix}-api"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-api-tg"
    jb_component = "api"
  })
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = var.https_listener_arn
  priority     = var.rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  dynamic "condition" {
    for_each = var.host_header == "" ? [] : [var.host_header]
    content {
      host_header {
        values = [condition.value]
      }
    }
  }

  dynamic "condition" {
    for_each = var.host_header == "" ? [1] : []
    content {
      path_pattern {
        values = ["/*"]
      }
    }
  }
}

resource "aws_ecs_service" "api" {
  name            = "${var.name_prefix}-api"
  cluster         = aws_ecs_cluster.jb.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.task_sg_id]
    assign_public_ip = var.give_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "jobbser-api"
    container_port   = var.app_port
  }

  # So someone can park Dev at 0 in the console overnight without Terraform fighting back.
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener_rule.api]

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-api"
    jb_component = "api"
  })
}
