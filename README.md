Backend is configured via `backend.hcl` and supplied to `terraform init` with
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





Terraform Plan 
plan:
    name: terraform-plan
    needs: setup
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: latest

      # Configure AWS Credentials using repository secrets
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan