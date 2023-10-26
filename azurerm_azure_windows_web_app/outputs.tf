output "current_tenant" {
  value = data.azurerm_client_config.current.tenant_id
}

output "current_object" {
  value = data.azurerm_client_config.current.object_id
}

output "sp_object" {
  value = data.azuread_service_principal.devops_sp.object_id
}