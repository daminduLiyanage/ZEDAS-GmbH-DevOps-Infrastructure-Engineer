terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

provider "random" {}

resource "azurerm_resource_group" "backend_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  generated_name = lower(substr("tfstate${random_id.suffix.hex}", 0, 24))
  sa_name        = var.storage_account_name != "" ? var.storage_account_name : local.generated_name
}

resource "azurerm_storage_account" "backend_sa" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.backend_rg.name
  location                 = azurerm_resource_group.backend_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "tfstate" {
  name               = var.container_name
  storage_account_id = azurerm_storage_account.backend_sa.id
  container_access_type = "private"
}
