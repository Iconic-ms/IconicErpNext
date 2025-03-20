data "external" "get_users" {
  program = ["bash", "-c", <<EOT
response=$(curl -s -X GET "${var.erpnext_url}/api/resource/User" \
-H "Authorization: token ${var.api_key}:${var.api_secret}")

# Escape double quotes and wrap response
escaped_response=$(echo "$response" | jq -Rs .)
echo "{\"result\": $escaped_response}"
EOT
  ]
}

data "external" "get_roles" {
  program = ["bash", "-c", <<EOT
response=$(curl -s -X GET "${var.erpnext_url}/api/resource/Role" \
-H "Authorization: token ${var.api_key}:${var.api_secret}")

# Escape double quotes and wrap response
escaped_response=$(echo "$response" | jq -Rs .)
echo "{\"result\": $escaped_response}"
EOT
  ]
}