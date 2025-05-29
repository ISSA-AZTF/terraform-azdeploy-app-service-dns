
variable "location" {
  type        = string
  description = "localisation des ressources "
}
variable "assigned_identity" {
  type        = string
  description = "Nom de l'identité managée"
}
variable "app_service_name" {
  type        = string
  description = "Le nom de l'app service"
}
variable "app_service_tag" {
  type        = string
  description = "Tag local visant la ressource app service "
}
variable "app_insight_tag" {
  type        = string
  description = "Tag local de la ressource app insight"
}
variable "global_tags" {
  type        = map(string)
  description = "Tags global pour toutes les ressources"
}
variable "identity_ids" {
  type        = string
  description = "Spécifies une Managed Identity "
}
variable "app_service_exist" {
  default = false
}
variable "app_insight_conf" {
  type = map(object({
    name                                  = string
    application_type                      = string
    daily_data_cap_in_gb                  = optional(number)
    daily_data_cap_notifications_disabled = optional(bool)
    retention_in_days                     = optional(number)
    disable_ip_masking                    = optional(bool)
  }))
}
variable "dns_zone" {
  type        = string
  description = "Nom de la zone DNS"
}
variable "dns_cname" {
  type        = list(string)
  description = "Nom du CNAME record"
}
variable "ssl_certificate" {
  type        = bool
  description = "Activer ou pas la liaison entre domaine personnalisé et certificat SSL "
}
variable "host_binding" {
  type        = string
  description = "Condition de création de la ressource SSL "
}
