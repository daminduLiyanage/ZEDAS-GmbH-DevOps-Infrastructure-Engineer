
## Cloning 

```bash
https://github.com/daminduLiyanage/ZEDAS-GmbH-DevOps-Infrastructure-Engineer.git
```


## Prerequisites

If not yet installed, install Terraform and Ansible

```bash
# Update your system and install required prerequisite packages
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# Install the HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the official HashiCorp repository to your system
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package lists again and install Terraform
sudo apt-get update && sudo apt-get install -y terraform

# Additional testing packages for local environment (not essential)

# Update pip to the latest version
python3 -m pip install --upgrade pip

# Install Ansible core engine and the Ansible Linter
pip install ansible-core ansible-lint

# Install required external infrastructure collections
ansible-galaxy collection install community.docker
```


These files and folders are needed before starting up:

- `ansible/keys/id_rsa`
- `ansible/inventory.ini`
- `terraform/backend.hcl`

> For demo purposes, a bash script (`create_files.sh`) is provided to generate some of the necessary files.

The backend is configured via `backend.hcl` and supplied to `terraform init` with `-backend-config`.

---

## Quickstart

> **TL;DR** — skip to the commands below.

```bash
# Run script once to generate sensitive files
chmod u+x create_files.sh
./create_files.sh
```

```bash
# Init the resources for state file
cd terraform/bootstrap/
terraform init
terraform plan
terraform apply
cd ../..

# Init resources
cd terraform
terraform init -backend-config=backend.hcl
terraform plan
terraform apply --auto-approve
cd ..

# Run Ansible scripts
cd ansible
ansible-playbook site.yml -i inventory.ini
cd ..

# Verify
ssh -i /home/dami/.ssh/azureterraformssh/id_rsa azureuser@<ip>

systemctl status docker
sudo su - zedasadmin
docker ps
exit
exit
```

## Destroy

```bash
# Destroy
cd terraform
terraform destroy
cd bootstrap
terraform destroy
cd ../..
```

---

## Troubleshooting

### Playbook check

```bash
ansible-playbook site.yml -i inventory.ini --check
```

> **Warning:** Some dependencies such as Python may cause later scripts to fail in check mode.

---

### Terraform initialisation fails

```bash
rm -rf .terraform/
terraform init -backend-config=backend.hcl
```

The first command clears the cache.

---

### Destroy fails

```bash
az group delete --name zedas-main-rg --yes --no-wait
```

If `terraform destroy` fails, delete the resource group through Azure directly.

---

### Key errors

```bash
chmod 600 keys/id_rsa
ssh-keygen -y -f keys/id_rsa
echo "" >> keys/id_rsa
```

Key errors can be caused by newlines, spaces, or Windows line endings. Check file permissions as well.

---

### Force destroy

```bash
terraform destroy --auto-approve
```

---

## CI/CD


CI/CD pipeline runs on push requests only. Whenever any branch is push it will check for terraform fmt, validation and tfsec. 
<image>

Once a PR is merged (afterwards) it will additionally trigger the ansible lint as well.
<image>


### Additional Notes: Trade-offs and next steps

#### Terraform Plan Step
The following step is a great trade off for non demo environemnts as it could be setup with including the credentials as well. Simply replace _ansible-lint_ of pipeline to implement.

```yaml
terraform-plan:
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
```

#### For PR requests
Current pipeline has push triggers only. It is ideal to use a pull trigger for PR requests, so it checks for any issues before merge as well. Important for branches such as main and release. 

```yaml
on:
  pull_request:
    branches: [ main, master, '**/release/**' ]

...

ansible-lint:
  name: ansible-lint
  needs: setup
  # Only runs on pull request events
  if: github.event_name == 'pull_request'
```