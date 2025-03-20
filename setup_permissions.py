from erpnext_api import erp_request

# Assign Timesheet Module to Employee Role
module_visibility = {
    "module_name": "Projects",
    "app_name": "erpnext",
    "restrict_to_role": "Employee"
}

print(erp_request("POST", "Module Def", module_visibility))

# Assign Read, Write, and Submit Permissions for Timesheets
permission_data = {
    "role": "Employee",
    "doctype": "Timesheet",
    "permlevel": 0,
    "read": 1,
    "write": 1,
    "submit": 1,
    "if_owner": 1
}

print(erp_request("POST", "Role Permission", permission_data))