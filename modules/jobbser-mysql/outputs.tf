output "endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "address" {
  value = aws_db_instance.mysql.address
}

output "port" {
  value = aws_db_instance.mysql.port
}

output "db_name" {
  value = aws_db_instance.mysql.db_name
}

output "sg_id" {
  value = aws_security_group.mysql.id
}
