from erpnext_api import erp_request

# 1️⃣ Inject Custom CSS to Match Unanet Theme
custom_css = """
.timesheet-grid {
    font-family: 'Arial', sans-serif;
    border: 1px solid #d1d5db;
    background-color: #f8f9fa;
    border-radius: 5px;
    box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);
}

.timesheet-grid th {
    background-color: #0073e6;
    color: white;
    padding: 10px;
    font-size: 14px;
    text-align: center;
}

.timesheet-grid td {
    border: 1px solid #d1d5db;
    padding: 8px;
    text-align: center;
    font-size: 13px;
    background-color: #ffffff;
}

.timesheet-grid td input {
    border: 1px solid #a0aec0;
    padding: 5px;
    width: 100%;
    border-radius: 3px;
    background-color: #ffffff;
}

.timesheet-grid td.holiday {
    background-color: #f3f4f6;
    font-weight: bold;
    color: #374151;
}

.btn-submit {
    background-color: #0073e6;
    color: white;
    font-weight: bold;
    padding: 10px 15px;
    border-radius: 5px;
    border: none;
    cursor: pointer;
}

.btn-submit:hover {
    background-color: #005bb5;
}

.timesheet-grid td.locked {
    background-color: #e5e7eb;
    pointer-events: none;
    opacity: 0.6;
}
"""

theme_data = {
    "doctype": "Website Theme",
    "theme": "Unanet Theme",
    "custom": 1,
    "custom_css": custom_css
}

print(erp_request("POST", "Website Theme", theme_data))

# 2️⃣ Inject Custom JavaScript for Grid Formatting
custom_js = """
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
"""

custom_script_data = {
    "doctype": "Custom Script",
    "script_type": "Client",
    "dt": "Timesheet",
    "script": custom_js
}

print(erp_request("POST", "Custom Script", custom_script_data))