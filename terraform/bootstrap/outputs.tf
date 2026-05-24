output "storage_account_name" {
  value = azurerm_storage_account.backend_sa.name
}

output "storage_account_id" {
  value = azurerm_storage_account.backend_sa.id
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
