# 🚀 ERPNext Timesheet System Setup Using Python

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

### **3️⃣ Run the Scripts**
Execute each script in order:

```bash
python setup_timesheet.py     # Creates Timesheet module & workflow
python setup_projects.py      # Creates projects & assigns employees
python setup_permissions.py   # Grants employees access to Timesheets
python setup_dashboard.py     # Adds shortcut to Timesheets in dashboard
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
```
## OR 

```bash
sh run_pythons.sh
# this will run all the python scripts in order.
```

✅ Your **ERPNext Timesheet system is now fully automated!** 🚀

