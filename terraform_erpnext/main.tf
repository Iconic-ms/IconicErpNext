

##############################
# Create Timesheet DocType
##############################
resource "null_resource" "create_timesheet_doctype" {
  provisioner "local-exec" {
    command = <<EOT
curl -X POST "${var.erpnext_url}/api/resource/DocType" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "doctype": "DocType",
  "name": "Timesheet",
  "fields": [
    {"fieldname": "project", "fieldtype": "Link", "options": "Project"},
    {"fieldname": "hours_worked", "fieldtype": "Float"},
    {"fieldname": "notes", "fieldtype": "Text"},
    {"fieldname": "status", "fieldtype": "Select", "options": "Draft\\nSubmitted\\nApproved"}
  ]
}'
EOT
  }
}

##############################
# Create Timesheet Workflow
##############################
resource "null_resource" "create_timesheet_workflow" {
  depends_on = [null_resource.create_timesheet_doctype]

  provisioner "local-exec" {
    command = <<EOT
curl -X POST "${var.erpnext_url}/api/resource/Workflow" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "doctype": "Workflow",
  "name": "Timesheet Approval",
  "document_type": "Timesheet",
  "is_active": 1,
  "states": [
    {"state": "Draft", "allow_edit": ["Employee"]},
    {"state": "Pending Approval", "allow_edit": ["Supervisor"]},
    {"state": "Approved", "allow_edit": []}
  ],
  "transitions": [
    {"action": "Submit", "state": "Draft", "next_state": "Pending Approval", "allowed": ["Employee"]},
    {"action": "Approve", "state": "Pending Approval", "next_state": "Approved", "allowed": ["Supervisor"]}
  ]
}'
EOT
  }
}

##############################
# Create Projects
##############################
resource "null_resource" "create_projects" {
  for_each = { for proj in var.projects : proj.project_id => proj }

  provisioner "local-exec" {
    command = <<EOT
curl -X POST "${var.erpnext_url}/api/resource/Project" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "project_name": "${each.value.project_name}",
  "name": "${each.value.project_id}",
  "manager": "${each.value.manager}"
}'
EOT
  }
}

##############################
# Create Users in ERPNext
##############################
resource "null_resource" "create_users" {
  for_each = { for proj in var.projects : proj.project_id => proj }

  provisioner "local-exec" {
    command = join("\n", [
      for emp in each.value.employees :
      <<EOC
curl -X POST "${var.erpnext_url}/api/resource/User" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d @- <<EOF
{
  "email": "${emp.user_email}",
  "first_name": "${split("@", emp.user_email)[0]}",
  "send_welcome_email": 0,
  "roles": [
    {"role": "${emp.role}"}
  ]
}
EOF
EOC
    ])
  }
}

##############################
# Assign Users to Projects (after user creation)
##############################
resource "null_resource" "assign_users_to_projects" {
  depends_on = [null_resource.create_users]

  for_each = { for proj in var.projects : proj.project_id => proj }

  provisioner "local-exec" {
    command = join("\n", [
      for emp in each.value.employees :
      <<EOC
curl -X POST "${var.erpnext_url}/api/resource/User%20Permission" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d @- <<EOF
{
  "user": "${emp.user_email}",
  "allow": "Project",
  "for_value": "${each.value.project_id}",
  "apply_to_all_doctypes": 0
}
EOF
EOC
    ])
  }
}

##############################
# Assign Timesheet Permissions to Employee Role
##############################
resource "null_resource" "assign_timesheet_permissions" {
  provisioner "local-exec" {
    command = <<EOT
curl -X POST "${var.erpnext_url}/api/resource/Role%20Permission%20for%20Page%20and%20Report" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "role": "Employee",
  "page_or_report": "Timesheet",
  "permission": "read"
}'

curl -X POST "${var.erpnext_url}/api/resource/Role%20Permission" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "role": "Employee",
  "doctype": "Timesheet",
  "permlevel": 0,
  "read": 1,
  "write": 1,
  "submit": 1,
  "if_owner": 1
}'
EOT
  }
}

##############################
# Create Employee Records Linked to Users
##############################
resource "null_resource" "create_employee_records" {
  depends_on = [null_resource.create_users]

  for_each = { for proj in var.projects : proj.project_id => proj }

  provisioner "local-exec" {
    command = join("\n", [
      for emp in each.value.employees :
      <<EOC
curl -X POST "${var.erpnext_url}/api/resource/Employee" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d @- <<EOF
{
  "employee_name": "${split("@", emp.user_email)[0]}",
  "status": "Active",
  "user_id": "${emp.user_email}",
  "designation": "${emp.role}",
  "date_of_joining": "2024-01-01"
}
EOF
EOC
    ])
  }
}
##############################
# 1. Assign Timesheet Module to Employee Role
##############################
resource "null_resource" "assign_timesheet_module_to_employee" {
  provisioner "local-exec" {
    command = <<EOT
# Assign Employee role to Timesheet module
curl -X POST "${var.erpnext_url}/api/resource/Module%20Def" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "module_name": "Projects",
  "app_name": "erpnext",
  "restrict_to_role": "Employee"
}'
EOT
  }
}

##############################
# 2. Assign Timesheet Doctype Permissions to Employee Role
##############################
resource "null_resource" "assign_timesheet_doctype_permissions" {
  depends_on = [null_resource.assign_timesheet_module_to_employee]

  provisioner "local-exec" {
    command = <<EOT
# Assign read, write, and submit permissions for Timesheet to Employee role
curl -X POST "${var.erpnext_url}/api/resource/Role%20Permission" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "role": "Employee",
  "doctype": "Timesheet",
  "permlevel": 0,
  "read": 1,
  "write": 1,
  "submit": 1,
  "if_owner": 1
}'
EOT
  }
}

##############################
# 3. Update Workspace to Show Timesheet for Employees
##############################
resource "null_resource" "update_workspace_with_timesheet" {
  depends_on = [null_resource.assign_timesheet_doctype_permissions]

  provisioner "local-exec" {
    command = <<EOT
# Add Timesheet to Projects workspace
curl -X PUT "${var.erpnext_url}/api/resource/Workspace/Projects" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "title": "Projects",
  "public": 1,
  "roles": ["Employee"],
  "content": [
    {
      "type": "card",
      "label": "Time Tracking",
      "items": [
        {
          "type": "doctype",
          "label": "Timesheet",
          "link_to": "Timesheet",
          "icon": "calendar",
          "color": "blue"
        }
      ]
    }
  ]
}'
EOT
  }
}

##############################
# 4. Add Timesheet Shortcut to Home Workspace
##############################
resource "null_resource" "add_timesheet_shortcut" {
  depends_on = [null_resource.update_workspace_with_timesheet]

  provisioner "local-exec" {
    command = <<EOT
# Create a shortcut for Timesheet in the Home workspace
curl -X POST "${var.erpnext_url}/api/resource/Workspace%20Shortcut" \
-H "Authorization: token ${var.api_key}:${var.api_secret}" \
-H "Content-Type: application/json" \
-d '{
  "shortcut_name": "Timesheet",
  "link_to": "Timesheet",
  "type": "doctype",
  "role": "Employee",
  "icon": "calendar",
  "label": "Timesheet"
}'
EOT
  }
}