#!/bin/bash

echo "🚀 Starting ERPNext Timesheet Setup..."

# Define the list of Python scripts to run in order
SCRIPTS=(
    "setup_timesheet.py"    # Creates Timesheet module & workflow
    "setup_projects.py"     # Creates projects & assigns employees
    "setup_permissions.py"  # Grants employees access to Timesheets
    "setup_dashboard.py"    # Adds shortcut to Timesheets in dashboard
    "setup_ui.py"           # Applies Unanet-style UI theme & custom JavaScript
)

# Loop through and run each script
for script in "${SCRIPTS[@]}"
do
    echo "▶ Running $script..."
    python "$script"
    
    # Check if the script ran successfully
    if [ $? -ne 0 ]; then
        echo "❌ Error in $script. Stopping setup."
        exit 1
    fi
done

echo "✅ ERPNext Timesheet Setup Completed Successfully!"