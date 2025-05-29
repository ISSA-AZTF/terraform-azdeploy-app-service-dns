#***************************
# Locals 
#**************************
locals {
  app_plan_name    = lower(format("%s-%s", "linux", "plan"))
  command          = "${path.module}\\Import_Docker.ps1 -RegistryName ${azurerm_container_registry.acr.name}"
  linux_fx_version = "Docker|${replace(azurerm_container_registry.acr.name, "_", "-")}.azurecr.io/hello-world:latest"
  app_insight_link = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app_insight["app_conf"].instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insight["app_conf"].connection_string
  }
}