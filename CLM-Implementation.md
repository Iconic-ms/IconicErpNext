# ERPNext Contract Lifecycle Management (CLM) System Setup Guide

This guide provides comprehensive step-by-step instructions for setting up a Contract Lifecycle Management (CLM) system in ERPNext. It includes creating a custom Contract DocType, an Obligation child table, configuring workflows, writing server and client scripts, setting up a public Web Form for obligation acknowledgment, and defining role-based permissions. All configurations are provided as code blocks ready to be copied into ERPNext.

## Prerequisites
- ERPNext instance (Version 14 or later recommended) installed and configured.
- System Manager role for creating DocTypes and configuring settings.
- Basic knowledge of Python, JavaScript, and ERPNext’s Frappe framework.
- Server script enabled in `site_config.json`:
  ```json
  {
    "server_script_enabled": true
  }
  ```
  Run the following command for self-hosted instances:
  ```bash
  bench --site [site_name] set-config server_script_enabled true
  ```
- Email account configured in ERPNext for sending notifications.
- Customer records with valid email IDs in the **Customer** DocType.

## Step 1: Create a Custom Contract DocType
This step creates a custom DocType named "CLM Contract" to manage contracts with fields for contract details, renewal tracking, and status.

### Sub-Steps
1. Navigate to **DocType List** in ERPNext (search for "DocType" in the Awesome Bar).
2. Click **New** to create a new DocType.
3. Configure the DocType with the following settings:
   - **Name**: `CLM Contract`
   - **Module**: `Custom`
   - **Is Single**: Unchecked (to allow multiple records)
4. Add the following fields in the **Fields** section:
   - **contract_name** (Data, Mandatory): Contract title.
   - **customer** (Link, Options: `Customer`, Mandatory): Linked customer.
   - **start_date** (Date, Mandatory): Contract start date.
   - **end_date** (Date): Contract end date (auto-calculated).
   - **duration_years** (Float, Default: `2`): Contract duration in years.
   - **renewal_window_days** (Int, Default: `45`): Days before end date for renewal.
   - **under_renewal_review** (Check): Flag for renewal review status.
   - **status** (Select, Options: `Draft,Active,Under Renewal,Expired,Cancelled`): Contract status.
   - **obligations** (Table, Options: `CLM Obligation`): Child table for obligations (created in Step 2).
5. Save the DocType.

### Code Block
```json
{
  "doctype": "DocType",
  "name": "CLM Contract",
  "module": "Custom",
  "is_single": 0,
  "fields": [
    {
      "fieldname": "contract_name",
      "label": "Contract Name",
      "fieldtype": "Data",
      "reqd": 1
    },
    {
      "fieldname": "customer",
      "label": "Customer",
      "fieldtype": "Link",
      "options": "Customer",
      "reqd": 1
    },
    {
      "fieldname": "start_date",
      "label": "Start Date",
      "fieldtype": "Date",
      "reqd": 1
    },
    {
      "fieldname": "end_date",
      "label": "End Date",
      "fieldtype": "Date"
    },
    {
      "fieldname": "duration_years",
      "label": "Duration (Years)",
      "fieldtype": "Float",
      "default": "2"
    },
    {
      "fieldname": "renewal_window_days",
      "label": "Renewal Window (Days)",
      "fieldtype": "Int",
      "default": "45"
    },
    {
      "fieldname": "under_renewal_review",
      "label": "Under Renewal Review",
      "fieldtype": "Check"
    },
    {
      "fieldname": "status",
      "label": "Status",
      "fieldtype": "Select",
      "options": "Draft\nActive\nUnder Renewal\nExpired\nCancelled"
    },
    {
      "fieldname": "obligations",
      "label": "Obligations",
      "fieldtype": "Table",
      "options": "CLM Obligation"
    }
  ],
  "permissions": [
    {
      "role": "System Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    },
    {
      "role": "Contract Manager",
      "read": 1,
      "write": 1,
      "create": 1
    },
    {
      "role": "Customer",
      "read": 1
    }
  ]
}
```

## Step 2: Create an Obligation Child Table
This step creates a child table DocType named "CLM Obligation" to track obligations linked to the Contract.

### Sub-Steps
1. Navigate to **DocType List** in ERPNext.
2. Click **New** to create a new DocType.
3. Configure the DocType with the following settings:
   - **Name**: `CLM Obligation`
   - **Module**: `Custom`
   - **Is Child Table**: Checked
4. Add the following fields in the **Fields** section:
   - **obligation_description** (Data, Mandatory): Description of the obligation.
   - **requires_acknowledgement** (Check): Flag for acknowledgment requirement.
   - **acknowledged** (Check): Flag for acknowledgment status.
   - **acknowledged_on** (Datetime): Date and time of acknowledgment.
5. Save the DocType.

### Code Block
```json
{
  "doctype": "DocType",
  "name": "CLM Obligation",
  "module": "Custom",
  "is_table": 1,
  "fields": [
    {
      "fieldname": "obligation_description",
      "label": "Obligation Description",
      "fieldtype": "Data",
      "reqd": 1
    },
    {
      "fieldname": "requires_acknowledgement",
      "label": "Requires Acknowledgement",
      "fieldtype": "Check"
    },
    {
      "fieldname": "acknowledged",
      "label": "Acknowledged",
      "fieldtype": "Check"
    },
    {
      "fieldname": "acknowledged_on",
      "label": "Acknowledged On",
      "fieldtype": "Datetime"
    }
  ],
  "permissions": [
    {
      "role": "System Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    },
    {
      "role": "Contract Manager",
      "read": 1,
      "write": 1,
      "create": 1
    },
    {
      "role": "Customer",
      "read": 1
    }
  ]
}
```

## Step 3: Configure Contract Workflow States and Transitions
This step sets up a workflow to manage the contract lifecycle with states and transitions.

### Sub-Steps
1. Navigate to **Workflow List** in ERPNext (search for "Workflow" in the Awesome Bar).
2. Click **New** to create a new Workflow.
3. Configure the Workflow with the following settings:
   - **Workflow Name**: `CLM Contract Workflow`
   - **DocType**: `CLM Contract`
   - **Is Active**: Checked
4. Add the following **Workflow States**:
   - Draft (Allow Edit: Contract Manager)
   - Active (Allow Edit: Contract Manager)
   - Under Renewal (Allow Edit: Contract Manager)
   - Expired
   - Cancelled
5. Add the following **Transitions**:
   - Draft → Active (Role: Contract Manager, Action: Activate, Condition: `doc.status == 'Draft'`)
   - Active → Under Renewal (Role: Contract Manager, Action: Start Renewal, Condition: `doc.under_renewal_review == 1`)
   - Under Renewal → Active (Role: Contract Manager, Action: Renew, Condition: `doc.status == 'Under Renewal'`)
   - Active → Expired (Role: Contract Manager, Action: Expire, Condition: `doc.end_date <= frappe.utils.nowdate()`)
   - Active → Cancelled (Role: Contract Manager, Action: Cancel)
6. Save the Workflow.

### Code Block
```json
{
  "doctype": "Workflow",
  "workflow_name": "CLM Contract Workflow",
  "document_type": "CLM Contract",
  "is_active": 1,
  "states": [
    {
      "state": "Draft",
      "doc_status": "0",
      "allow_edit": "Contract Manager"
    },
    {
      "state": "Active",
      "doc_status": "1",
      "allow_edit": "Contract Manager"
    },
    {
      "state": "Under Renewal",
      "doc_status": "1",
      "allow_edit": "Contract Manager"
    },
    {
      "state": "Expired",
      "doc_status": "1"
    },
    {
      "state": "Cancelled",
      "doc_status": "2"
    }
  ],
  "transitions": [
    {
      "state": "Draft",
      "action": "Activate",
      "next_state": "Active",
      "allowed": "Contract Manager",
      "condition": "doc.status == 'Draft'"
    },
    {
      "state": "Active",
      "action": "Start Renewal",
      "next_state": "Under Renewal",
      "allowed": "Contract Manager",
      "condition": "doc.under_renewal_review == 1"
    },
    {
      "state": "Under Renewal",
      "action": "Renew",
      "next_state": "Active",
      "allowed": "Contract Manager",
      "condition": "doc.status == 'Under Renewal'"
    },
    {
      "state": "Active",
      "action": "Expire",
      "next_state": "Expired",
      "allowed": "Contract Manager",
      "condition": "doc.end_date <= frappe.utils.nowdate()"
    },
    {
      "state": "Active",
      "action": "Cancel",
      "next_state": "Cancelled",
      "allowed": "Contract Manager"
    }
  ]
}
```

## Step 4: Write Python Server Scripts
This step creates server scripts to automate contract end date calculation, renewal reminders, and obligation notifications.

### 4.1 Auto-Calculate End Date
This script calculates the contract end date based on the start date and duration when the contract is saved.

#### Sub-Steps
1. Navigate to **Server Script List** in ERPNext (search for "Server Script" in the Awesome Bar).
2. Click **New** to create a new Server Script.
3. Configure the script with the following settings:
   - **Script Type**: `DocType Event`
   - **Reference Doctype**: `CLM Contract`
   - **DocType Event**: `Before Save`
4. Add the script below.
5. Save the Server Script.

#### Code Block
```python
from frappe.utils import add_years

if doc.start_date and doc.duration_years:
    doc.end_date = add_years(doc.start_date, int(doc.duration_years))
```

### 4.2 Send Contract Renewal Reminder
This script sends a renewal reminder email 30 days before the 45-day renewal window for active contracts.

#### Sub-Steps
1. Navigate to **Server Script List** in ERPNext.
2. Click **New** to create a new Server Script.
3. Configure the script with the following settings:
   - **Script Type**: `Scheduled Job`
   - **Reference Doctype**: `CLM Contract`
   - **Scheduled Job Type**: `Daily`
4. Add the script below.
5. Save the Server Script.

#### Code Block
```python
from frappe.utils import add_days, nowdate, getdate
from frappe.email.queue import send

contracts = frappe.get_all("CLM Contract", filters={"status": "Active"}, fields=["name", "end_date", "renewal_window_days", "customer"])

for contract in contracts:
    renewal_date = add_days(getdate(contract.end_date), -contract.renewal_window_days)
    reminder_date = add_days(renewal_date, -30)
    if getdate(nowdate()) == getdate(reminder_date):
        customer = frappe.get_doc("Customer", contract.customer)
        frappe.db.set_value("CLM Contract", contract.name, "under_renewal_review", 1)
        send(
            recipients=[customer.email_id],
            subject=f"Renewal Reminder for Contract {contract.name}",
            message=f"Dear {customer.customer_name},\n\nThe contract {contract.name} is approaching its renewal window on {renewal_date}. Please review.",
            reference_doctype="CLM Contract",
            reference_name=contract.name
        )
```

### 4.3 Notify Customers on New Obligation
This script sends a notification to the customer when a new obligation requiring acknowledgment is added to a contract.

#### Sub-Steps
1. Navigate to **Server Script List** in ERPNext.
2. Click **New** to create a new Server Script.
3. Configure the script with the following settings:
   - **Script Type**: `DocType Event`
   - **Reference Doctype**: `CLM Contract`
   - **DocType Event**: `After Save`
4. Add the script below.
5. Save the Server Script.

#### Code Block
```python
from frappe.email.queue import send

for obligation in doc.obligations:
    if obligation.requires_acknowledgement and not obligation.acknowledged:
        customer = frappe.get_doc("Customer", doc.customer)
        send(
            recipients=[customer.email_id],
            subject=f"New Obligation Requires Acknowledgment for Contract {doc.name}",
            message=f"Dear {customer.customer_name},\n\nA new obligation '{obligation.obligation_description}' requires your acknowledgment for contract {doc.name}. Please acknowledge via the web form.",
            reference_doctype="CLM Contract",
            reference_name=doc.name
        )
```

## Step 5: Write JavaScript Client Scripts for Web Form
This step creates a client script to handle obligation acknowledgment in the public Web Form, adding buttons for customers to acknowledge obligations.

### Sub-Steps
1. Navigate to **Client Script List** in ERPNext (search for "Client Script" in the Awesome Bar).
2. Click **New** to create a new Client Script.
3. Configure the script with the following settings:
   - **DocType**: `CLM Contract`
   - **Enabled**: Checked
4. Add the script below.
5. Save the Client Script.

### Code Block
```javascript
frappe.ui.form.on('CLM Contract', {
    refresh(frm) {
        if (frm.doc.obligations) {
            frm.doc.obligations.forEach(row => {
                if (row.requires_acknowledgement && !row.acknowledged) {
                    frm.add_custom_button(`Acknowledge ${row.obligation_description}`, () => {
                        frappe.call({
                            method: "frappe.client.set_value",
                            args: {
                                doctype: "CLM Obligation",
                                name: row.name,
                                fieldname: {
                                    acknowledged: 1,
                                    acknowledged_on: frappe.datetime.now_datetime()
                                }
                            },
                            callback: function(r) {
                                if (!r.exc) {
                                    frappe.msgprint("Obligation acknowledged successfully.");
                                    frm.refresh();
                                }
                            }
                        });
                    });
                }
            });
        }
    }
});
```

## Step 6: Create a Public Web Form for Obligation Acknowledgment
This step creates a public Web Form to allow customers to view and acknowledge obligations.

### Sub-Steps
1. Navigate to **Web Form List** in ERPNext (search for "Web Form" in the Awesome Bar).
2. Click **New** to create a new Web Form.
3. Configure the Web Form with the following settings:
   - **Title**: `Acknowledge Obligations`
   - **DocType**: `CLM Contract`
   - **Module**: `Custom`
   - **Is Standard**: Unchecked
   - **Allow Edit**: Checked
   - **Allow Multiple**: Unchecked
   - **Login Required**: Checked
   - **Allow Guest to View**: Checked
4. Add the following fields in the **Fields** section:
   - `contract_name` (Data, Read Only)
   - `customer` (Link, Options: `Customer`, Read Only)
   - `status` (Select, Read Only)
   - `obligations` (Table, Options: `CLM Obligation`)
5. Set **Route**: `acknowledge-obligations`
6. Save and publish the Web Form.

### Code Block
```json
{
  "doctype": "Web Form",
  "title": "Acknowledge Obligations",
  "doc_type": "CLM Contract",
  "module": "Custom",
  "is_standard": 0,
  "allow_edit": 1,
  "allow_multiple": 0,
  "login_required": 1,
  "allow_guest_to_view": 1,
  "route": "acknowledge-obligations",
  "fields": [
    {
      "fieldname": "contract_name",
      "fieldtype": "Data",
      "label": "Contract Name",
      "read_only": 1
    },
    {
      "fieldname": "customer",
      "fieldtype": "Link",
      "options": "Customer",
      "label": "Customer",
      "read_only": 1
    },
    {
      "fieldname": "status",
      "fieldtype": "Select",
      "label": "Status",
      "read_only": 1
    },
    {
      "fieldname": "obligations",
      "fieldtype": "Table",
      "options": "CLM Obligation",
      "label": "Obligations"
    }
  ]
}
```

## Step 7: Configure Role-Based Permissions
This step sets up role-based permissions for the Contract and Obligation DocTypes to control access.

### Sub-Steps
1. For both **CLM Contract** and **CLM Obligation** DocTypes, configure permissions:
   - Navigate to **DocType List**, open **CLM Contract** and **CLM Obligation**.
   - In the **Permissions** section, set:
     - **System Manager**: Full access (Read, Write, Create, Delete).
     - **Contract Manager**: Read, Write, Create.
     - **Customer**: Read-only.
2. Create a custom role **Contract Manager** if not already present:
   - Navigate to **Role List** (search for "Role" in the Awesome Bar).
   - Click **New**, set **Role Name**: `Contract Manager`.
   - Save the Role.
3. Assign the **Contract Manager** role to relevant users:
   - Navigate to **User List** (search for "User" in the Awesome Bar).
   - Open a user, add the **Contract Manager** role in the **Roles** section.
4. Ensure customers have the **Customer** role:
   - Open the user linked to a customer in **User List**.
   - Add the **Customer** role in the **Roles** section.

### Code Block (for Contract Manager Role)
```json
{
  "doctype": "Role",
  "role_name": "Contract Manager"
}
```

## Testing the Setup
Follow these steps to verify the CLM system setup:

1. **Create a Contract**:
   - Navigate to **CLM Contract List** and create a new contract.
   - Fill in `contract_name`, `customer`, `start_date`, and add an obligation in the `obligations` table with `requires_acknowledgement` checked.
   - Save the contract and verify the `end_date` is auto-calculated (start date + 2 years).
2. **Test Workflow Transitions**:
   - Move the contract from **Draft** to **Active** using the "Activate" action.
   - Set `under_renewal_review` to checked and transition to **Under Renewal** using the "Start Renewal" action.
3. **Verify Obligation Notification**:
   - Check the customer’s email for a notification about the new obligation requiring acknowledgment.
4. **Test Web Form**:
   - Log in as a customer user (with the **Customer** role).
   - Access the Web Form at `/acknowledge-obligations`.
   - Verify that an "Acknowledge" button appears for obligations requiring acknowledgment.
   - Click the button and confirm the `acknowledged` and `acknowledged_on` fields are updated.
5. **Test Renewal Reminder**:
   - Manually set a contract’s `end_date` to a date 75 days from now (45-day renewal window + 30-day reminder).
   - Run the scheduled job manually (via `bench execute` or wait for the daily schedule).
   - Verify the customer receives a renewal reminder email and `under_renewal_review` is set to 1.

### Manual Job Execution (for Testing)
To test the renewal reminder script manually:
```bash
bench --site [site_name] execute frappe.email.queue.flush
```

## Troubleshooting
- **Server Scripts Not Running**: Ensure `server_script_enabled` is set to `true` in `site_config.json`.
- **Emails Not Sending**: Verify email settings in **Email Account** (Setup > Email > Email Account) and ensure a valid SMTP server is configured.
- **Web Form Access Denied**: Confirm the customer user has the **Customer** role and **Login Required** is enabled in the Web Form.
- **Workflow Issues**: Check that the **Contract Manager** role is assigned to the user and conditions in transitions are met.
- **Customer Not Receiving Notifications**: Validate that the customer record has a valid `email_id` in the **Customer** DocType.
- **Script Errors**: Check the ERPNext **Error Log** (search for "Error Log" in the Awesome Bar) for debugging.

For additional support, visit the [ERPNext Forum](https://discuss.erpnext.com).
