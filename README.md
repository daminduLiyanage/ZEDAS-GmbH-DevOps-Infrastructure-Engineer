terraform init -backend-config=backend.hcl


az group delete --name zedas-main-rg --yes --no-wait




ansible-playbook site.yml -i inventory.ini --check 
