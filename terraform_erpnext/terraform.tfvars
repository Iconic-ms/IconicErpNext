erpnext_url = "http://54.221.57.26:8000"
api_key     = "c1cca0ad534dee1"
api_secret  = "b824879c3a56661"

projects = [
  {
    project_id   = "PROJ001"
    project_name = "Website Redesign"
    manager      = "manager@example.com"
    employees = [
      { user_email = "employee1@example.com", role = "Employee" },
      { user_email = "supervisor@example.com", role = "Supervisor" }
    ]
  },
  {
    project_id   = "PROJ002"
    project_name = "App Development"
    manager      = "manager2@example.com"
    employees = [
      { user_email = "employee2@example.com", role = "Employee" },
      { user_email = "supervisor2@example.com", role = "Supervisor" }
    ]
  }
]