
#***********************
# Nombre aléatoire
#***********************
resource "random_id" "unique_name" {
  byte_length = 4
}

#***********************
# Chaîne de caractère aléatoire
#***********************
resource "random_string" "random" {
  length  = 5
  lower   = true
  numeric = false
  special = false
  upper   = false
}

#***********************
# app service plan ( existant)
#***********************
data "azurerm_app_service_plan" "app_svc_plan" {
  name                = local.app_plan_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
#***********************
# Resource group Data source
#***********************
data "azurerm_resource_group" "rg" {
  name = "rg"
}

#***********************
# Managed Identity
#***********************
resource "azurerm_user_assigned_identity" "managed_identity" {
  location            = var.location
  name                = var.assigned_identity
  resource_group_name = data.azurerm_resource_group.rg.name
}

#***********************
# Rôle assignment
#***********************
resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

#***********************
# Azure container registry
#***********************
resource "azurerm_container_registry" "acr" {
  name                = format("%s%s", "registry", random_string.random.result)
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
}

#***********************
# Data Provisioner
#***********************
resource "terraform_data" "docker_image" {
  triggers_replace = [
    azurerm_container_registry.acr.id
  ]

  provisioner "local-exec" {

    command     = local.command
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [azurerm_container_registry.acr]
}

#***********************
# App service 
#***********************
resource "azurerm_app_service" "app" {
  name                = coalesce(var.app_service_name, "app-svc-${substr((random_id.unique_name.hex), 0, 4)}")
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = data.azurerm_app_service_plan.app_svc_plan.id
  https_only          = true
  tags                = merge({ Resource_type = format("%s", var.app_service_tag) }, var.global_tags)


  site_config {
    always_on         = true
    linux_fx_version  = local.linux_fx_version
    health_check_path = "/health"
  }

  identity {
    type         = length(var.identity_ids) > 0 ? "UserAssigned" : null
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  app_settings = local.app_insight_link

  lifecycle {
    ignore_changes = [tags, app_settings, site_config]
  }
  depends_on = [azurerm_application_insights.app_insight]
}

#***********************
# Dns zone Data source
#***********************
data "azurerm_dns_zone" "dns" {
  name                = var.dns_zone
  resource_group_name = data.azurerm_resource_group.rg.name
}


#***********************
# Dns cname record
#***********************
resource "azurerm_dns_cname_record" "app_record" {
  name                = element(var.dns_cname, 0)
  zone_name           = data.azurerm_dns_zone.dns.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  record              = azurerm_app_service.app.default_site_hostname
}
#***********************
# Txt record => Prouver la propriété du domaine personnalisé
#***********************
resource "azurerm_dns_txt_record" "txt_record" {
  name                = "asuid.${azurerm_dns_cname_record.app_record.name}"
  zone_name           = data.azurerm_dns_zone.dns.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  record {
    value = azurerm_app_service.app.custom_domain_verification_id
  }
}

#***********************************
# Domaine personnalisé - app service 
#***********************************
resource "azurerm_app_service_custom_hostname_binding" "cust_domaine" {
  hostname            = trim(azurerm_dns_cname_record.app_record.fqdn, ".")
  app_service_name    = azurerm_app_service.app.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_dns_txt_record.txt_record]
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

#***********************
# Certificat SSL
#***********************
resource "azurerm_app_service_managed_certificate" "ssl" {
  count                      = var.ssl_certificate == true ? 1 : 0
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.cust_domaine.id
  depends_on                 = [azurerm_dns_txt_record.txt_record]
}

#***********************
# SSL- Domaine DNS personnalisé
#***********************
resource "azurerm_app_service_certificate_binding" "ssl_cust_domaine" {
  count               = var.ssl_certificate && length(var.host_binding) > 0 ? 1 : 0
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.cust_domaine.id
  certificate_id      = azurerm_app_service_managed_certificate.ssl[0].id
  ssl_state           = var.host_binding != null ? "SniEnabled" : null
}

#****************************
# App insight
#***************************
resource "azurerm_application_insights" "app_insight" {
  for_each             = var.app_insight_conf
  name                 = format("appi-%s", random_id.unique_name.hex)
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  application_type     = each.value.application_type
  daily_data_cap_in_gb = each.value.daily_data_cap_in_gb
  retention_in_days    = each.value.retention_in_days # Par défaut 90 jours 
  disable_ip_masking   = each.value.disable_ip_masking
  tags                 = merge({ Resource_type = "${var.app_insight_tag}" }, var.global_tags)
}
