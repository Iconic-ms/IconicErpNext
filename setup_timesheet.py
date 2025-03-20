from erpnext_api import erp_request

# Create Timesheet Doctype
timesheet_structure = {
    "doctype": "DocType",
    "name": "Timesheet",
    "module": "Projects",
    "fields": [
        {"fieldname": "project", "fieldtype": "Link", "options": "Project"},
        {"fieldname": "hours_worked", "fieldtype": "Float"},
        {"fieldname": "notes", "fieldtype": "Text"},
        {"fieldname": "status", "fieldtype": "Select", "options": "Draft\\nSubmitted\\nApproved"},
        {"fieldname": "locked", "fieldtype": "Check", "default": 0},
        {"fieldname": "employee", "fieldtype": "Link", "options": "Employee"}
    ]
}

print(erp_request("POST", "DocType", timesheet_structure))

# Define Approval Workflow
workflow_data = {
    "doctype": "Workflow",
    "document_type": "Timesheet",
    "workflow_name": "Timesheet Approval",
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
}

print(erp_request("POST", "Workflow", workflow_data))