locals {
  # Short prefix so ALB / TG names stay under AWS limits.
  name_prefix = "jb-${var.jb_env}"

  base_tags = {
    jb_project  = "jobbser"
    jb_env      = var.jb_env
    managed_by  = "terraform"
    billed_to   = var.billed_to
  }

  api_desired = var.park_api ? 0 : var.api_task_count
}
