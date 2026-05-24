variable "customer_name" {
  description = "Short name for the customer used as a prefix for resources"
  type        = string
}

variable "location" {
  description = "Azure region to deploy into, e.g. eastus"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Size of the VM to create"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key to provision for the admin user. Leave empty to generate a key locally (not recommended for production)."
  type        = string
  default     = ""
}

variable "ssh_allowed_cidr" {
  description = "CIDR range allowed to SSH into VM (e.g. your public IP as /32). This is required to avoid exposing SSH to the world."
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\\\.){3}[0-9]{1,3}\\/([1-9][0-9]?|0)$", var.ssh_allowed_cidr))
    error_message = "ssh_allowed_cidr must be a valid IPv4 CIDR (for example: 203.0.113.45/32)"
  }
}
