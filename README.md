terraform init -backend-config=backend.hcl 

terraform apply --auto-approve

az group delete --name zedas-main-rg --yes --no-wait



chmod 600 keys/id_rsa
ssh-keygen -y -f keys/id_rsa
echo "" >> keys/id_rsa 
ansible-playbook site.yml -i inventory.ini --check 

ssh -i /home/dami/.ssh/azureterraformssh/id_rsa azureuser@<ip>

systemctl status docker
sudo su - zedasadmin
docker ps



# Remove the local cache directory
rm -rf .terraform/

# Re-initialize with your backend file
terraform init -backend-config=backend.hcl

terraform destroy --auto-approve
