# Access Module: Manages Cloudflare Zero Trust Access applications and policies for Red and Blue teams
# Simplified version compatible with Cloudflare provider 4.52.0

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
      service  = "http://localhost:5601"
    }
    
    # Grafana ingress rule
    ingress_rule {
      hostname = var.grafana_domain
      service  = "http://localhost:3000"
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
}

# Red Team Access Application
resource "cloudflare_zero_trust_access_application" "red_team" {
  account_id = var.account_id
  name       = "${var.red_team_name} Application"
  domain     = var.red_team_app_domain
  type       = "self_hosted"
  session_duration = "24h"
}

# Blue Team Access Application
resource "cloudflare_zero_trust_access_application" "blue_team" {
  account_id = var.account_id
  name       = "${var.blue_team_name} Application"
  domain     = var.blue_team_app_domain
  type       = "self_hosted"
  session_duration = "24h"
}

# Wazuh Application
resource "cloudflare_zero_trust_access_application" "wazuh" {
  account_id = var.account_id
  name       = "Wazuh Security Platform"
  domain     = var.wazuh_domain
  type       = "self_hosted"
  session_duration = "8h"
}

# Grafana Application
resource "cloudflare_zero_trust_access_application" "grafana" {
  account_id = var.account_id
  name       = "Grafana Monitoring Dashboard"
  domain     = var.grafana_domain
  type       = "self_hosted"
  session_duration = "8h"
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
}