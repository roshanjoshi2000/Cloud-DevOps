output "alb_dns" {
  description = "Hit this for /health once something is running"
  value       = module.edge.alb_dns
}

output "ecs_cluster" {
  value = module.api.cluster_name
}

output "ecs_service" {
  value = module.api.service_name
}

output "mysql_endpoint" {
  value = module.mysql.endpoint
}

output "uploads_bucket" {
  value = module.uploads.bucket_name
}

output "runtime_secret_arn" {
  value = module.runtime_secret.arn
}

output "park_api" {
  value = var.park_api
}

output "nat_on" {
  value = module.edge.nat_enabled
}
