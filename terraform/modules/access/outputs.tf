# Application Outputs
output "red_team_app_id" {
  description = "ID of the Red Team application"
  value       = cloudflare_zero_trust_access_application.red_team.id
}

output "blue_team_app_id" {
  description = "ID of the Blue Team application"
  value       = cloudflare_zero_trust_access_application.blue_team.id
}

output "red_team_app_domain" {
  description = "Domain of the Red Team application"
  value       = cloudflare_zero_trust_access_application.red_team.domain
}

output "blue_team_app_domain" {
  description = "Domain of the Blue Team application"
  value       = cloudflare_zero_trust_access_application.blue_team.domain
}

# Removed shared_app_domain output since we removed the shared app

# Wazuh Application Outputs
output "wazuh_app_id" {
  description = "ID of the Wazuh application"
  value       = cloudflare_zero_trust_access_application.wazuh.id
}

output "wazuh_app_domain" {
  description = "Domain of the Wazuh application"
  value       = cloudflare_zero_trust_access_application.wazuh.domain
}

# Grafana Application Outputs
output "grafana_app_id" {
  description = "ID of the Grafana application"
  value       = cloudflare_zero_trust_access_application.grafana.id
}

output "grafana_app_domain" {
  description = "Domain of the Grafana application"
  value       = cloudflare_zero_trust_access_application.grafana.domain
}

# Tunnel Outputs
output "monitoring_tunnel_id" {
  description = "ID of the monitoring tunnel"
  value       = cloudflare_zero_trust_tunnel_cloudflared.monitoring.id
}

output "monitoring_tunnel_secret" {
  description = "Secret for the monitoring tunnel"
  value       = random_id.monitoring_tunnel_secret.b64_std
  sensitive   = true
}

output "monitoring_tunnel_cname" {
  description = "CNAME value for the monitoring tunnel"
  value       = "${cloudflare_zero_trust_tunnel_cloudflared.monitoring.id}.cfargotunnel.com"
}

output "wazuh_tunnel_token" {
  description = "Token for Wazuh tunnel authentication"
  value       = cloudflare_zero_trust_tunnel_cloudflared.monitoring.tunnel_token
  sensitive   = true
}