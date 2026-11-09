variable "name_prefix" {
  type = string
}

variable "secret_path" {
  description = "Secrets Manager name. Inventory prefers one bundle per env."
  type        = string
  default     = ""
}

variable "placeholder_json" {
  description = "Fake starter JSON. Real values get set in console/CLI after apply. Terraform ignores later edits."
  type        = string
  sensitive   = true
  default     = <<-JSON
    {
      "db_password": "CHANGE_ME",
      "connection_string": "CHANGE_ME",
      "jwt_signing_key": "CHANGE_ME",
      "stripe_secret_key": "CHANGE_ME",
      "firebase_credentials_json": "{}",
      "msghub_url": "https://CHANGE_ME"
    }
  JSON
}

variable "tags" {
  type    = map(string)
  default = {}
}
