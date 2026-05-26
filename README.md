# ZEDAS GmbH — DevOps Infrastructure

This repository contains the infrastructure-as-code and configuration management setup for the ZEDAS GmbH DevOps environment. It provisions cloud resources on Azure using Terraform, manages VM configuration with Ansible, and enforces quality gates through a GitHub Actions CI/CD pipeline.

## Contents

- [Prerequisites](#prerequisites)
- [Quickstart](#quickstart) — _jump straight to the commands_
- [Destroy](#destroy)
- [Troubleshooting](#troubleshooting)
- [VM Unreachable Runbook](#vm-unreachable-runbook)
- [CI/CD](#cicd)
- [Trade-offs and next steps](#additional-notes-trade-offs-and-next-steps)

---

## Cloning

```bash
git clone https://github.com/daminduLiyanage/ZEDAS-GmbH-DevOps-Infrastructure-Engineer.git
```

---

## Prerequisites

If not yet installed, install Terraform and Ansible:

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

> **TL;DR** — [skip to the commands](#quickstart)

These files and folders are needed before starting up:

- `ansible/keys/id_rsa`
- `ansible/inventory.ini`
- `terraform/backend.hcl`

> For demo purposes, a bash script (`create_files.sh`) is provided to generate some of the necessary files.

The backend is configured via `backend.hcl` and supplied to `terraform init` with `-backend-config`.

---

## Quickstart

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

---

## Destroy

```bash
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

> **Warning:** Note having some dependencies such as Python may cause check mode fail.

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

## VM Unreachable Runbook


If the VM is unreachable try the following:

1. **Check the Platform Power State**

   `az vm get-instance-view --name <vm-name> --resource-group <rg-name> --query "instanceView.statuses[1].displayStatus"`
   
   Check if the VM is powered on through portal or this command.

2. **Check Security Groups / Firewalls**
   
   `az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name> --output table`
   
   Check portal for Security groups. Check if the rules are not enabled or blocking. Ensure the Network Security Group in Azure explicitly allows Inbound TCP Port 22 from local machine's public IP address

3. **Verify Public IP**

   `ping <VM_IP>`
   
   Check if target address get resolved correctly.

4. **Try SSH with Verbose**
   
   `ssh -vvv user@<VM_IP>`
   
   Trace the network hops to see exactly where the connection drops.

5. **Port Query**
   
   `nc -zv <VM_IP> 22`
   
   Check if the specific remote management port handshake can complete.

6. **Key not having permissions**
   
   `chmod 600 id_rsa`
   
   It could be the key that is not having permissions to read properly. 

7. **Reset SSH Configuration**

   Go to your VM page in the Azure Portal. Scroll down to Help, click Reset password, select Reset SSH configuration only, and apply it to fix.

8. **Redeploy**

    If nothing works try restarting through azure portal. Still if there is no sign try redeploying.



---

## CI/CD

The CI/CD pipeline runs on push events only. Whenever any branch is pushed, it checks for `terraform fmt`, validation, and tfsec.

<img width="383" height="187" alt="{4BD1E762-0C04-42AC-B434-60F0A937F5F4}" src="https://github.com/user-attachments/assets/eb9d16cd-7156-4d4c-9811-cf633b4eed29" />

Once a PR is merged it will additionally trigger the Ansible lint as well.

<img width="385" height="192" alt="{CBA61C6D-7915-4A3B-A225-24853D272C01}" src="https://github.com/user-attachments/assets/354b812f-c9d6-498f-82f8-dab7b984176f" />


---

### Additional Notes: Trade-offs and Next Steps

#### Terraform Plan Step

The following step is a useful trade-off for non-demo environments, as it can be configured to include credentials as well. Simply replace the `ansible-lint` job in the pipeline to implement it.

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

#### For PR Requests

The current pipeline has push triggers only. It is ideal to add a pull request trigger as well, so issues are caught before a merge. This is particularly important for branches such as `main` and `release`.

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
