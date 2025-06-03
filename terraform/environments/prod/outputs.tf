# Red Team Application Outputs
output "red_team_app_domain" {
  description = "Domain for the Red Team application"
  value       = module.access.red_team_app_domain
}

# Blue Team Application Outputs  
output "blue_team_app_domain" {
  description = "Domain for the Blue Team application"
  value       = module.access.blue_team_app_domain
}

# Monitoring Application Outputs
output "wazuh_app_domain" {
  description = "Domain for Wazuh security platform"
  value       = module.access.wazuh_app_domain
}

output "grafana_app_domain" {
  description = "Domain for Grafana monitoring dashboard"
  value       = module.access.grafana_app_domain
}

# WARP Enrollment URL - use red team domain as example
output "warp_enrollment_url" {
  description = "URL for WARP client enrollment"
  value       = "https://${module.access.red_team_app_domain}/warp"
}

# Tunnel Configuration Outputs
output "monitoring_tunnel_id" {
  description = "ID of the monitoring tunnel for Wazuh and Grafana"
  value       = module.access.monitoring_tunnel_id
}

output "monitoring_tunnel_cname" {
  description = "CNAME target for tunnel DNS records"
  value       = module.access.monitoring_tunnel_cname
}

# Team Configuration Outputs
output "red_team_group_id" {
  description = "ID of the Red Team access group"
  value       = module.idp.red_team_id
}

output "blue_team_group_id" {
  description = "ID of the Blue Team access group" 
  value       = module.idp.blue_team_id
}

output "azure_idp_id" {
  description = "ID of the Azure AD identity provider"
  value       = module.idp.entra_idp_id
}

# Device Posture Outputs
output "device_posture_rules" {
  description = "List of device posture rule IDs"
  value       = module.device_posture.all_posture_rule_ids
}

# Gateway Settings
output "account_id" {
  description = "Cloudflare account ID"
  value       = var.account_id
}

# Application URLs for easy access
output "application_urls" {
  description = "Quick reference URLs for all applications"
  value = {
    red_team = "https://${module.access.red_team_app_domain}"
    blue_team = "https://${module.access.blue_team_app_domain}"
    wazuh = "https://${module.access.wazuh_app_domain}"
    grafana = "https://${module.access.grafana_app_domain}"
  }
}