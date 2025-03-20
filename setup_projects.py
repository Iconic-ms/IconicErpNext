from erpnext_api import erp_request

# Create Projects
projects = [
    {"project_name": "Project A", "project_id": "PROJ001", "manager": "manager@example.com"},
    {"project_name": "Project B", "project_id": "PROJ002", "manager": "manager@example.com"}
]

for project in projects:
    project_data = {
        "doctype": "Project",
        "project_name": project["project_name"],
        "name": project["project_id"],
        "manager": project["manager"]
    }
    print(erp_request("POST", "Project", project_data))

# Assign Users to Projects
assignments = [
    {"user": "employee1@example.com", "project": "PROJ001"},
    {"user": "employee2@example.com", "project": "PROJ002"}
]

for assign in assignments:
    permission_data = {
        "user": assign["user"],
        "allow": "Project",
        "for_value": assign["project"],
        "apply_to_all_doctypes": 0
    }
    print(erp_request("POST", "User Permission", permission_data))