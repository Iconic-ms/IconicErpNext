# 🚀 ERPNext Timesheet System Setup - Manual Guide

This guide walks you through **manually setting up** the Timesheet module in ERPNext, including workflow, permissions, projects, and UI customization.

---

## ✅ Features Implemented
- 📌 **Create a Timesheet module** to track employee hours.
- 📌 **Restrict employees to assigned projects**.
- 📌 **Enforce approval workflow**: Employees submit → Supervisor approves.
- 📌 **Auto-fill holidays with 8 hours** (locked field).
- 📌 **UI updates to match Unanet-style grid**.
- 📌 **Add a Timesheet shortcut to the dashboard** for employees.

---

## 🛠️ **Step-by-Step Manual Setup**

### **1️⃣ Configure API Authentication (For Reference Only)**
1. Log in to your ERPNext instance:  
   ➤ [http://54.221.57.26:8000/#login](http://54.221.57.26:8000/#login)
2. Go to **Settings → Users and Permissions → Users**.
3. Select the **Admin user** and **generate API Keys**.
4. Copy the **API Key** and **API Secret**.
5. Save them for API integrations if needed.

---

### **2️⃣ Create the Timesheet Doctype**
1. Go to **Customization → Doctype**.
2. Click **New** and create a new Doctype named **Timesheet**.
3. Add the following fields:

   | Fieldname      | Fieldtype  | Options     |
   |---------------|------------|-------------|
   | project       | Link       | Project     |
   | hours_worked  | Float      |             |
   | notes        | Text       |             |
   | status       | Select     | Draft\nSubmitted\nApproved |
   | locked       | Check      | Default: 0  |
   | employee     | Link       | Employee    |

4. Click **Save** and **Publish**.

---

### **3️⃣ Set Up the Approval Workflow**
1. Go to **Settings → Workflow**.
2. Click **New Workflow** and set:
   - **Workflow Name:** `Timesheet Approval`
   - **Document Type:** `Timesheet`
   - **Is Active:** ✅ Yes
3. Define **Workflow States**:

   | State Name       | Allow Edit By   |
   |----------------|---------------|
   | Draft          | Employee       |
   | Pending Approval | Supervisor     |
   | Approved       | None (Locked)  |

4. Define **Workflow Actions**:

   | Action Name | State Before     | State After      | Allowed To |
   |------------|----------------|----------------|------------|
   | Submit     | Draft          | Pending Approval | Employee   |
   | Approve    | Pending Approval | Approved       | Supervisor |

5. Click **Save and Publish**.

---

### **4️⃣ Create Projects and Assign Employees**
1. Go to **Projects → New Project**.
2. Create projects and assign a **Manager**.
3. Go to **Settings → Users and Permissions → User Permission**.
4. Assign **User → Project → (Employee Name) → (Project Name)**.
5. Click **Save**.

---

### **5️⃣ Assign Permissions to Employees**
1. Go to **Settings → Role Permissions Manager**.
2. Select **Timesheet** from the **Doctype** dropdown.
3. Modify permissions for **Employee**:
   - ✅ Read
   - ✅ Write
   - ✅ Submit
   - 🔲 Delete (Disabled)
4. Click **Save**.

---

### **6️⃣ Apply Unanet-Style UI Theme**
1. Go to **Website → Website Theme**.
2. Click **New Theme** → Name it **Unanet Theme**.
3. Paste the following in **Custom CSS**:

```css
.timesheet-grid th {
    background-color: #0073e6;
    color: white;
    padding: 10px;
}

.timesheet-grid td {
    border: 1px solid #d1d5db;
    padding: 8px;
    text-align: center;
}

.timesheet-grid td.holiday {
    background-color: #f3f4f6;
    font-weight: bold;
}

.timesheet-grid td.locked {
    background-color: #e5e7eb;
    pointer-events: none;
    opacity: 0.6;
}
```

4. Click **Save & Apply**.

---

### **7️⃣ Add JavaScript for Grid Formatting**
1. Go to **Customization → Custom Script**.
2. Click **New Script** → Select **Client Script**.
3. Set **Doctype = Timesheet**.
4. Paste this script:

```javascript
frappe.ui.form.on('Timesheet', {
    refresh: function(frm) {
        $('table[data-fieldname="time_logs"]').addClass("timesheet-grid");

        $('td[data-fieldname="hours_worked"]').each(function() {
            var day = $(this).closest('tr').find('td[data-fieldname="date"]').text();
            if (isHoliday(day)) {
                $(this).addClass("holiday").prop('readonly', true);
            }
        });

        if (frm.doc.status === "Approved") {
            $('td[data-fieldname="hours_worked"], td[data-fieldname="notes"]').addClass("locked").prop('readonly', true);
        }
    }
});

function isHoliday(date) {
    let holidays = ["2025-01-01", "2025-07-04", "2025-12-25"];
    return holidays.includes(date);
}
```

5. Click **Save & Enable**.

---

### **8️⃣ Add Timesheet Shortcut to Dashboard**
1. Go to **Settings → Workspace → New Shortcut**.
2. Set:
   - **Shortcut Name:** `Timesheet`
   - **Link To:** `Timesheet`
   - **Icon:** `calendar`
   - **Role:** `Employee`
3. Click **Save**.



