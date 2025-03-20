output "users_list" {
  value = data.external.get_users.result
}

output "roles_list" {
  value = data.external.get_roles.result
}