
output "app_service_url" {
  value       = azurerm_app_service.app.default_site_hostname
  description = "L'url de l'app service"
}
output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "Nom du container registry"
}
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "Login server de l'ACR"
}
output "managed_identity_id" {
  value       = azurerm_user_assigned_identity.managed_identity.id
  description = "ID de l'identité managée"
}