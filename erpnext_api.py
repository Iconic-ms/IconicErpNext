import requests

# ERPNext instance details
ERP_URL = "<server_url>"  # Replace with your ERPNext instance URL
API_KEY = "api_key"
API_SECRET = "api_secret"

HEADERS = {
    "Authorization": f"token {API_KEY}:{API_SECRET}",
    "Content-Type": "application/json"
}

# Function to make API calls
def erp_request(method, endpoint, data=None):
    url = f"{ERP_URL}/api/resource/{endpoint}"
    response = requests.request(method, url, headers=HEADERS, json=data)
    return response.json() if response.status_code == 200 else response.text