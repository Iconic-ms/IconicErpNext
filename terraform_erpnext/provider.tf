provider "http" {}

provider "null" {}

locals {
  auth_header = "token ${var.api_key}:${var.api_secret}"
}