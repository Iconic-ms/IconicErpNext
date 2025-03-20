# 🚀 ERPNext Timesheet System Setup Using Python

# 📌 ERPNext Timesheet System - Requirements

This document outlines the **requirements** for setting up a **Timesheet System** in **ERPNext**, ensuring it functions similarly to Unanet’s timesheet features.

## ✅ **Core Requirements**

1. **Project Management**
   - Admin should be able to **create projects** with unique **Project IDs**.
   - Admin should be able to **assign Project IDs** to specific employees.

2. **Employee Project Selection**
   - Employees should only be able to select **assigned Project IDs** in the timesheet grid.
   - Each row in the timesheet grid should be **restricted to one project**.
   - Employees should be able to **log hours for multiple projects**, meaning multiple rows can exist per pay period.

3. **Bi-Weekly Pay Period Enforcement**
   - Employees should only be able to create **bi-weekly** timesheets.

4. **Overtime Handling**
   - If an employee **logs more than 8 hours in a day**, they must **provide a reason** for the extra hours.
   - If the **total hours exceed 80 in a pay period**, the employee must **justify extra hours** before submission.

5. **Time-Off and Holidays**
   - PTO (Paid Time Off) and Out of Office should be **available in the project selection dropdown**.
   - **Holidays should auto-fill with 8 hours** and be **non-editable**.

6. **Timesheet Submission & Approval Workflow**
   - Employees should be able to **save the timesheet** before submitting it.
   - Employees should have a **separate Submit button**.
   - Once submitted, **employees should not be able to edit the timesheet**.
   - **Project admins or project managers** should be able to **unlock the timesheet** for employees to make changes and resubmit.

7. **User Role-Based Access Control**
   - **Only project admins and project managers** should be able to see **all employees' timesheets**.

8. **Grid Layout & Automatic Date Population**
   - The timesheet should be **presented as a structured grid**.
   - **First column** should be the **Project Name**.
   - **Second column** should be the **Project ID** (auto-filled when the project is selected).
   - The **remaining columns should represent each day in the pay period**, with dates automatically populated.

---

## 📌 **Implementation Options**

This Timesheet System can be implemented in **ERPNext** using:
- **Python scripts with API integration** ✅
- **Manual configuration in the ERPNext UI** ✅
- **Terraform automation for ERPNext** ✅
- **Power Apps for alternative implementation** ✅

🚀 **This document ensures that the Timesheet System meets business needs effectively!**

This repository contains **Python scripts** to **automate the setup of a Timesheet system** in **ERPNext** using the ERPNext REST API.

## ✅ Features Implemented
- 📌 **Admin can create projects** with unique Project IDs.
- 📌 **Employees can log hours for multiple projects** in a Timesheet grid.
- 📌 **Approval workflow enforced:** Employees submit → Supervisor approves.
- 📌 **Restricts employees to assigned projects** (no unauthorized access).
- 📌 **Timesheet validation rules**:
  - ⏳ Employees **must provide a reason** for overtime (8+ hours).
  - ⏳ Cannot submit timesheet if **exceeding 80 hours per pay period** without justification.
- 📌 **Holidays auto-fill with 8 hours** (locked field).
- 📌 **Dashboard shortcut for Timesheets** for quick access.

---


## 🛠️ **Setup Instructions**

### **1️⃣ Install Required Libraries**
Ensure `requests` is installed for API communication:

```bash
pip install requests
```

---

### **2️⃣ Configure ERPNext API Authentication**
1. Log in to your ERPNext instance:  
   ➤ [http://54.221.57.26:8000/#login](http://54.221.57.26:8000/#login)
2. Go to **Settings → Users and Permissions → Users**.
3. Select the **Admin user** and **generate API Keys**.
4. Copy the **API Key** and **API Secret**.
5. Open **`erpnext_api.py`** and replace:

```python
API_KEY = "your_api_key"
API_SECRET = "your_api_secret"
```

---


## 📂 **Project Structure**
```
📁 erpnext-timesheet-setup
│── 📄 erpnext_api.py           # API authentication & request functions
│── 📄 setup_timesheet.py       # Creates Timesheet module & workflow
│── 📄 setup_projects.py        # Creates projects & assigns employees
│── 📄 setup_permissions.py     # Assigns correct permissions
│── 📄 setup_dashboard.py       # Adds Timesheet shortcut to employee dashboard
│── 📄 README.md                # This documentation
Run Scripts
│── 📄 run_pythons.sh              # Run all scripts together
Terraform_erpnext
│── 📄 terraform_erpnect            # All terraform code test
```

---

## 🚀 **Running the Scripts**
Execute each script **one by one** in your terminal:
I put this in bash script file call run_pythons.sh

```bash
python setup_timesheet.py     # Creates Timesheet module & workflow
python setup_projects.py      # Creates projects & assigns employees
python setup_permissions.py   # Grants employees access to Timesheets
python setup_dashboard.py     # Adds shortcut to Timesheets in dashboard
python setup_ui.py            # Applies Unanet-style UI theme & custom JavaScript
```
## OR 

```bash
sh run_pythons.sh
# this will run all the python scripts in order.
```

✅ Your **ERPNext Timesheet system is now fully automated!** 🚀

