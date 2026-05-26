#!/bin/bash

# This script generates the necessary secret file templates (with no actualdata) for Ansible and Terraform to work together

# Exit for non-zero
set -e
YELLOW='\033[1;33m'
NC='\033[0m' # No Color / Reset


echo "Starting file generation script..."

mkdir -p ansible/keys

# 1. Generate ansible/keys/id_rsa
echo "Generating ansible/keys/id_rsa..."
cat << 'EOF' > ansible/keys/id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
<INSERT_PRIVATE_KEY_CONTENT_HERE>
-----END OPENSSH PRIVATE KEY-----
EOF

# Permissions
chmod 600 ansible/keys/id_rsa
# Append EOF at end
echo "" >> ansible/keys/id_rsa

echo -e "${YELLOW}ansible/keys/id_rsa created. Please place the key manually${NC}"

# 2. Generate ansible/inventory.ini
echo "Generating ansible/inventory.ini..."
cat << 'EOF' > ansible/inventory.ini
[webservers]
<ip_address_from_terraform> ansible_user=azureuser ansible_ssh_private_key_file=keys/id_rsa
EOF
echo -e "${YELLOW}ansible/inventory.ini file created. Please place IP address manually${NC}"

# 4. Generate terraform/backend.hcl
echo "Generating terraform/backend.hcl..."
cat << 'EOF' > terraform/backend.hcl
# External Backend configuration for Terraform AzureRM
resource_group_name  = "#"
storage_account_name = "#"
container_name       = "#"
key                  = "terraform.tfstate"
EOF

echo -e "${YELLOW}terraform/backend.hcl created. Insert values manually.${NC}"


echo "All files successfully generated!"