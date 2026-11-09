variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets across 2 AZs"
  type        = list(string)
}

variable "client_sg_ids" {
  description = "SGs allowed on 3306. For Dev I pass the Jobbser-Api task SG created in the stack root."
  type        = list(string)
}

variable "secret_arn" {
  description = "Secret JSON must include db_password"
  type        = string
}

variable "mysql_version" {
  type    = string
  default = "8.0"
}

variable "instance_class" {
  # Inventory hint: small / t4g.micro-class in cost notes
  type    = string
  default = "db.t4g.micro"
}

variable "storage_gb" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "jobbser"
}

variable "master_user" {
  type    = string
  default = "jb_admin"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_days" {
  type    = number
  default = 3
}

variable "allow_destroy" {
  description = "true in Dev so tear-down is not painful"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
