output "teams_account_id" {
  value = module.warp.teams_account_id
}

output "shared_app_domain" {
  value       = module.access.shared_app_domain
  description = "Domain for the shared application"
}

output "red_team_app_domain" {
  value       = module.access.red_team_app_domain
  description = "Domain for the Red Team application"
}

output "blue_team_app_domain" {
  value       = module.access.blue_team_app_domain
  description = "Domain for the Blue Team application"
}

output "warp_enrollment_url" {
  value       = "https://${module.access.shared_app_domain}/warp"
  description = "URL for WARP client enrollment"
}

# Monitoring Applications
output "wazuh_app_domain" {
  value       = module.access.wazuh_app_domain
  description = "Domain for the Wazuh application"
}

output "grafana_app_domain" {
  value       = module.access.grafana_app_domain
  description = "Domain for the Grafana application"
}

# Tunnel Information for Azure Workspace
output "monitoring_tunnel_id" {
  value       = module.access.monitoring_tunnel_id
  description = "ID of the monitoring tunnel for Azure AKS"
}

output "monitoring_tunnel_secret" {
  value       = module.access.monitoring_tunnel_secret
  description = "Secret for the monitoring tunnel (use in Azure workspace)"
  sensitive   = true
}

output "monitoring_tunnel_cname" {
  value       = module.access.monitoring_tunnel_cname
  description = "CNAME record for the monitoring tunnel"
}

output "wazuh_tunnel_token" {
  value       = module.access.wazuh_tunnel_token
  description = "Tunnel token for cloudflared authentication"
  sensitive   = true
}

# Instructions for Azure Implementation
output "azure_implementation_instructions" {
  value = <<-EOT
    
    === AZURE IMPLEMENTATION INSTRUCTIONS ===
    
    1. Use the following tunnel token in your Azure AKS/VM:
       - Tunnel ID: ${module.access.monitoring_tunnel_id}
       - Use the 'wazuh_tunnel_token' output as the authentication token
    
    2. Install cloudflared on your Azure VM/AKS:
       ```bash
       # For Ubuntu/Debian
       curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
       sudo dpkg -i cloudflared.deb
       
       # Authenticate with the tunnel token
       sudo cloudflared service install <TUNNEL_TOKEN>
       ```
    
    3. DNS Records to create:
       - ${module.access.wazuh_app_domain} CNAME ${module.access.monitoring_tunnel_cname}
       - ${module.access.grafana_app_domain} CNAME ${module.access.monitoring_tunnel_cname}
    
    4. Access URLs:
       - Wazuh: https://${module.access.wazuh_app_domain}
       - Grafana: https://${module.access.grafana_app_domain}
    
    5. Security Notes:
       - Both applications require Intune-compliant devices
       - Device posture checks must pass (AV, disk encryption, OS version)
       - Session monitoring is enabled
       - Data download/upload restrictions are in place for Wazuh
    
  EOT
  description = "Implementation instructions for Azure workspace"
}