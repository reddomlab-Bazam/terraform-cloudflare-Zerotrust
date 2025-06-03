# Access Module: Manages Cloudflare Zero Trust Access applications and policies for Red and Blue teams
# Enhanced with monitoring applications (Wazuh, Grafana) and tunnel support

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
  }
}

# Generate tunnel secret
resource "random_id" "monitoring_tunnel_secret" {
  byte_length = 32
}

# Monitoring Tunnel for Wazuh and Grafana
resource "cloudflare_zero_trust_tunnel_cloudflared" "monitoring" {
  account_id = var.account_id
  name       = "monitoring-tunnel"
  secret     = random_id.monitoring_tunnel_secret.b64_std
}

# Tunnel Configuration
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "monitoring" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.monitoring.id

  config {
    # Wazuh ingress rule
    ingress_rule {
      hostname = var.wazuh_domain
      service  = "http://localhost:5601"  # Wazuh web interface port
      origin_request {
        http_host_header = var.wazuh_domain
        connect_timeout  = "30s"
        tls_timeout      = "30s"
        tcp_keep_alive   = "30s"
        no_happy_eyeballs = false
        keep_alive_connections = 1024
        keep_alive_timeout = "1m30s"
      }
    }
    
    # Grafana ingress rule
    ingress_rule {
      hostname = var.grafana_domain
      service  = "http://localhost:3000"  # Grafana default port
      origin_request {
        http_host_header = var.grafana_domain
        connect_timeout  = "30s"
        tls_timeout      = "30s"
        tcp_keep_alive   = "30s"
        no_happy_eyeballs = false
        keep_alive_connections = 1024
        keep_alive_timeout = "1m30s"
      }
    }
    
    # Catch-all rule (required)
    ingress_rule {
      service = "http_status:404"
    }
  }
}

# Shared application (accessible by both teams)
resource "cloudflare_zero_trust_access_application" "app" {
  account_id           = var.account_id
  name                 = var.app_name
  domain               = "reddome.org"
  type                 = "self_hosted"
  session_duration     = "24h"
  app_launcher_visible = true
  
  # Enhanced security settings
  auto_redirect_to_identity = true
  enable_binding_cookie    = true
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "strict"
  
  # CORS settings for better security
  cors_headers {
    allowed_methods = ["GET", "POST", "OPTIONS"]
    allowed_origins = ["https://*.reddome.org"]
    allow_credentials = true
    max_age = 86400
  }
}

# Red Team Access Application
resource "cloudflare_zero_trust_access_application" "red_team" {
  account_id = var.account_id
  name       = "${var.red_team_name} Application"
  domain     = var.red_team_app_domain
  type       = "self_hosted"
  session_duration = "24h"
  
  auto_redirect_to_identity = true
  enable_binding_cookie    = true
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "strict"
}

# Blue Team Access Application
resource "cloudflare_zero_trust_access_application" "blue_team" {
  account_id = var.account_id
  name       = "${var.blue_team_name} Application"
  domain     = var.blue_team_app_domain
  type       = "self_hosted"
  session_duration = "24h"
  
  auto_redirect_to_identity = true
  enable_binding_cookie    = true
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "strict"
}

# Wazuh Application
resource "cloudflare_zero_trust_access_application" "wazuh" {
  account_id = var.account_id
  name       = "Wazuh Security Platform"
  domain     = var.wazuh_domain
  type       = "self_hosted"
  session_duration = "8h"  # Shorter session for security tools
  
  auto_redirect_to_identity = true
  enable_binding_cookie    = true
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "strict"
  
  # Enhanced security for monitoring tools
  cors_headers {
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allowed_origins = ["https://${var.wazuh_domain}"]
    allow_credentials = true
    max_age = 3600
  }
}

# Grafana Application
resource "cloudflare_zero_trust_access_application" "grafana" {
  account_id = var.account_id
  name       = "Grafana Monitoring Dashboard"
  domain     = var.grafana_domain
  type       = "self_hosted"
  session_duration = "8h"  # Shorter session for security tools
  
  auto_redirect_to_identity = true
  enable_binding_cookie    = true
  http_only_cookie_attribute = true
  same_site_cookie_attribute = "strict"
  
  cors_headers {
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allowed_origins = ["https://${var.grafana_domain}"]
    allow_credentials = true
    max_age = 3600
  }
}

# Policy for email-based access to the shared app
resource "cloudflare_zero_trust_access_policy" "email_policy" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.app.id
  name           = "Email Access Policy"
  precedence     = 2
  decision       = "allow"

  include {
    email = var.allowed_emails
  }
  
  # Require device compliance
  require {
    device_posture = var.device_posture_rule_ids
  }
}

# Red Team Access Policy
resource "cloudflare_zero_trust_access_policy" "red_team" {
  account_id = var.account_id
  name       = "${var.red_team_name} Access Policy"
  application_id = cloudflare_zero_trust_access_application.red_team.id
  decision   = "allow"
  precedence = 1

  include {
    group = [var.red_team_group_id]
  }

  require {
    device_posture = var.device_posture_rule_ids
  }
  
  # Session controls
  session_controls {
    monitor_session = true
    disable_download = false
    disable_upload = false
    disable_copy_paste = false
  }
}

# Blue Team Access Policy
resource "cloudflare_zero_trust_access_policy" "blue_team" {
  account_id = var.account_id
  name       = "${var.blue_team_name} Access Policy"
  application_id = cloudflare_zero_trust_access_application.blue_team.id
  decision   = "allow"
  precedence = 2

  include {
    group = [var.blue_team_group_id]
  }

  require {
    device_posture = var.device_posture_rule_ids
  }
  
  session_controls {
    monitor_session = true
    disable_download = false
    disable_upload = false
    disable_copy_paste = false
  }
}

# Wazuh Access Policy - Both teams can access
resource "cloudflare_zero_trust_access_policy" "wazuh_access" {
  account_id = var.account_id
  name       = "Wazuh Security Access Policy"
  application_id = cloudflare_zero_trust_access_application.wazuh.id
  decision   = "allow"
  precedence = 1

  include {
    group = [var.red_team_group_id, var.blue_team_group_id]
  }

  require {
    device_posture = var.device_posture_rule_ids
  }
  
  # Enhanced session controls for security tools
  session_controls {
    monitor_session = true
    disable_download = true  # Prevent data exfiltration
    disable_upload = true
    disable_copy_paste = true
  }
}

# Grafana Access Policy - Both teams can access
resource "cloudflare_zero_trust_access_policy" "grafana_access" {
  account_id = var.account_id
  name       = "Grafana Monitoring Access Policy"
  application_id = cloudflare_zero_trust_access_application.grafana.id
  decision   = "allow"
  precedence = 1

  include {
    group = [var.red_team_group_id, var.blue_team_group_id]
  }

  require {
    device_posture = var.device_posture_rule_ids
  }
  
  session_controls {
    monitor_session = true
    disable_download = false  # Allow downloading charts/reports
    disable_upload = true
    disable_copy_paste = false
  }
}

# Additional security policy - Block access from non-compliant devices
resource "cloudflare_zero_trust_access_policy" "block_non_compliant" {
  account_id = var.account_id
  name       = "Block Non-Compliant Devices"
  application_id = cloudflare_zero_trust_access_application.wazuh.id
  decision   = "deny"
  precedence = 100  # Lower precedence = evaluated last

  include {
    everyone = true
  }
  
  exclude {
    device_posture = var.device_posture_rule_ids
  }
}