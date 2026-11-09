output "cluster_name" {
  value = aws_ecs_cluster.jb.name
}

output "service_name" {
  value = aws_ecs_service.api.name
}

output "task_role_name" {
  value = aws_iam_role.task.name
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "log_group" {
  value = aws_cloudwatch_log_group.api.name
}

output "target_group_arn" {
  value = aws_lb_target_group.api.arn
}
