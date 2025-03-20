from erpnext_api import erp_request

# Add Timesheet Shortcut to Employee Dashboard
shortcut_data = {
    "shortcut_name": "Timesheet",
    "link_to": "Timesheet",
    "type": "doctype",
    "role": "Employee",
    "icon": "calendar",
    "label": "Timesheet"
}

print(erp_request("POST", "Workspace Shortcut", shortcut_data))

# Ensure Employees See the Correct Workspace
workspace_data = {
    "module_name": "Projects",
    "app_name": "erpnext",
    "restrict_to_role": "Employee"
}

print(erp_request("POST", "Module Def", workspace_data))