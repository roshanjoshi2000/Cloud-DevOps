variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Usually private subnets"
  type        = list(string)
}

variable "task_sg_id" {
  description = "Pre-created SG for API tasks. Stack creates it so MySQL can allow it before this module runs."
  type        = string
}

variable "https_listener_arn" {
  type = string
}

variable "api_image_uri" {
  description = "ECR image for Jobbser-Api"
  type        = string
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory_mib" {
  type    = number
  default = 512
}

variable "task_count" {
  description = "0 parks Dev overnight without deleting the service"
  type        = number
  default     = 1
}

variable "give_public_ip" {
  type    = bool
  default = false
}

variable "runtime_secret_arn" {
  type = string
}

variable "rule_priority" {
  type    = number
  default = 50
}

variable "host_header" {
  description = "Empty = forward /* for early Dev. Set api.dev... when DNS exists."
  type        = string
  default     = ""
}

variable "log_days" {
  type    = number
  default = 7
}

variable "aspnet_env" {
  type    = string
  default = "Development"
}

variable "tags" {
  type    = map(string)
  default = {}
}
