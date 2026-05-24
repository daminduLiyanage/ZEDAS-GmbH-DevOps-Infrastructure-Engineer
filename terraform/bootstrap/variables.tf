variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "storage_account_name" {
  description = "terraform state storage account"
  type        = string
  default     = "zedasterraformstate"
}

variable "container_name" {
  type    = string
  default = "tfstate"
}
