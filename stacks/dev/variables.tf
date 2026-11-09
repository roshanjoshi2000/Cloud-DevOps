variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "jb_env" {
  type    = string
  default = "dev"
}

variable "billed_to" {
  description = "Who gets the Cost Explorer stare when Dev is left on"
  type        = string
  default     = "roshan"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "az_names" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.40.0.0/24", "10.40.1.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.40.10.0/24", "10.40.11.0/24"]
}

variable "create_nat" {
  description = "I default to one NAT. Flip false only if we accept public-IP tasks for a while."
  type        = bool
  default     = true
}

variable "acm_cert_arn" {
  type    = string
  default = "arn:aws:acm:eu-west-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"
}

variable "api_image_uri" {
  type    = string
  default = "000000000000.dkr.ecr.eu-west-1.amazonaws.com/jobbser-api:dev-placeholder"
}

variable "park_api" {
  description = "If true, task_count becomes 0 (park overnight / weekends)."
  type        = bool
  default     = false
}

variable "api_task_count" {
  description = "Used when park_api is false"
  type        = number
  default     = 1
}

variable "give_tasks_public_ip" {
  type    = bool
  default = false
}

variable "mysql_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "app_port" {
  type    = number
  default = 8080
}
