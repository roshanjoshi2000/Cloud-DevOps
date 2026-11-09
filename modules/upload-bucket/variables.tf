variable "name_prefix" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = true
}

variable "expire_old_versions_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
