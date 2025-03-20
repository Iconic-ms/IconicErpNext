variable "erpnext_url" {
  description = "URL of the ERPNext instance"
  type        = string
}

variable "api_key" {
  description = "ERPNext API Key"
  type        = string
}

variable "api_secret" {
  description = "ERPNext API Secret"
  type        = string
}

variable "projects" {
  description = "List of projects with assigned users and roles"
  type = list(object({
    project_id   = string
    project_name = string
    manager      = string
    employees    = list(object({
      user_email = string
      role       = string
    }))
  }))
}