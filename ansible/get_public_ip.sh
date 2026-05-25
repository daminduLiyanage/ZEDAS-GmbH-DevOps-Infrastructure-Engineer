#!/bin/bash

INI_FILE="inventory.ini"

if [ -f "$INI_FILE" ]; then
    echo "Existing $INI_FILE found. Deleting it..."
    rm "$INI_FILE"
fi
echo "[webservers]" > "$INI_FILE"
terraform -chdir=../terraform output -raw public_ip >> "$INI_FILE"
echo "Check $INI_FILE"
exit 0