output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "alb_arn" {
  value = aws_lb.public.arn
}

output "alb_dns" {
  value = aws_lb.public.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "nat_enabled" {
  value = var.create_nat
}
