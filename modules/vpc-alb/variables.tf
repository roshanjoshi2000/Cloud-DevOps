variable "name_prefix" {
  description = "Short prefix, e.g. jb-dev"
  type        = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "az_names" {
  description = "Two AZs minimum for ALB"
  type        = list(string)
}

variable "public_cidrs" {
  type = list(string)
}

variable "private_cidrs" {
  type = list(string)
}

variable "create_nat" {
  description = "One NAT in the first public subnet. Off = cheaper Dev experiment with public tasks."
  type        = bool
  default     = true
}

variable "acm_cert_arn" {
  description = "Placeholder ACM ARN for HTTPS listener"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
