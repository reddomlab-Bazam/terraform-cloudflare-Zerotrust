# WARP Module: Manages Cloudflare WARP client configuration and logging
# Fixed version compatible with Cloudflare provider version 4.52.0

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Security blocks - using consolidated security categories
resource "cloudflare_zero_trust_gateway_policy" "consolidated_security_blocks" {
  account_id  = var.account_id
  name        = "Block All Security Threats"
  description = "Block all security threats and malware based on Cloudflare's threat intelligence"
  precedence  = 10
  action      = "block"
  filters     = ["dns"]
  traffic     = "any(dns.security_category[*] in {4 7 9 80})"
  enabled     = true
}

# Content filtering for DNS
resource "cloudflare_zero_trust_gateway_policy" "content_filtering_dns" {
  account_id  = var.account_id
  name        = "Content Filtering DNS Policy"
  description = "Block inappropriate content DNS requests"
  precedence  = 20
  action      = "block"
  filters     = ["dns"]
  traffic     = "any(dns.content_category[*] in {1 4 5 6 7})"
  enabled     = true
}

# Content filtering for HTTP 
resource "cloudflare_zero_trust_gateway_policy" "content_filtering_http" {
  account_id  = var.account_id
  name        = "Content Filtering HTTP Policy"
  description = "Block inappropriate content HTTP requests"
  precedence  = 21
  action      = "block"
  filters     = ["http"]
  traffic     = "any(http.request.uri.content_category[*] in {1 4 5 6 7})"
  enabled     = true
}

# Block streaming services
resource "cloudflare_zero_trust_gateway_policy" "block_streaming" {
  account_id  = var.account_id
  name        = "Block Streaming"
  description = "Block unauthorized streaming platforms"
  precedence  = 30
  action      = "block"
  filters     = ["http"]
  traffic     = "any(http.request.uri.content_category[*] in {96})"
  enabled     = true
}

# File upload blocking with exceptions for approved services
resource "cloudflare_zero_trust_gateway_policy" "block_file_uploads" {
  account_id  = var.account_id
  name        = "Block Unauthorized File Uploads"
  description = "Block file uploads to unauthorized services"
  precedence  = 40
  action      = "block"
  filters     = ["http"]
  traffic     = "http.request.method == \"POST\" and http.request.uri matches \".*upload.*\" and not(http.request.uri matches \".*(sharepoint|onedrive|teams).*\")"
  enabled     = true
}

# Security tools allowlist - DNS only with proper syntax for domains
resource "cloudflare_zero_trust_gateway_policy" "security_tools_dns" {
  account_id  = var.account_id
  name        = "Security Tools DNS Allow"
  description = "Allow security tools domains"
  precedence  = 5
  action      = "allow"
  filters     = ["dns"]
  traffic     = "any(dns.domains[*] in {\"kali.org\" \"metasploit.com\" \"hackerone.com\" \"splunk.com\" \"elastic.co\" \"sentinelone.com\"})"
  enabled     = true
}

# Security tools allowlist - HTTP
resource "cloudflare_zero_trust_gateway_policy" "security_tools_http" {
  account_id  = var.account_id
  name        = "Security Tools HTTP Allow"
  description = "Allow security tools URLs"
  precedence  = 6
  action      = "allow"
  filters     = ["http"]
  traffic     = "http.request.uri matches \".*security-tools.*\" or http.request.uri matches \".*security-monitor.*\""
  enabled     = true
}

# Allow access to essential categories (education, business, government)
resource "cloudflare_zero_trust_gateway_policy" "allow_essential_categories" {
  account_id  = var.account_id
  name        = "Allow Essential Categories"
  description = "Allow access to educational, business, and government sites"
  precedence  = 50
  action      = "allow"
  filters     = ["http"]
  traffic     = "any(http.request.uri.content_category[*] in {12 13 18})"
  enabled     = true
}

# General internet access (simplified - no user group filtering)
resource "cloudflare_zero_trust_gateway_policy" "general_internet_access" {
  account_id  = var.account_id
  name        = "General Internet Access"
  description = "Allow general internet access for authenticated users"
  precedence  = 200
  action      = "allow"
  filters     = ["dns"]
  traffic     = "dns.domains[*] matches \".*\""
  enabled     = true
}

# WARP enrollment application
resource "cloudflare_zero_trust_access_application" "warp_enrollment_app" {
  account_id                = var.account_id
  session_duration          = "24h"
  name                      = "${var.warp_name} - Device Enrollment"
  allowed_idps              = [var.azure_ad_provider_id]
  auto_redirect_to_identity = true
  type                      = "warp"
  app_launcher_visible      = false

  lifecycle {
    create_before_destroy = true
  }
}

# Team-specific WARP enrollment policies
resource "cloudflare_zero_trust_access_policy" "red_team_warp_policy" {
  application_id = cloudflare_zero_trust_access_application.warp_enrollment_app.id
  account_id     = var.account_id
  name           = "Red Team WARP Access"
  decision       = "allow"
  precedence     = 1

  include {
    azure {
      id                   = var.red_team_group_ids
      identity_provider_id = var.azure_ad_provider_id
    }
  }
}

resource "cloudflare_zero_trust_access_policy" "blue_team_warp_policy" {
  application_id = cloudflare_zero_trust_access_application.warp_enrollment_app.id
  account_id     = var.account_id
  name           = "Blue Team WARP Access"
  decision       = "allow"
  precedence     = 2

  include {
    azure {
      id                   = var.blue_team_group_ids
      identity_provider_id = var.azure_ad_provider_id
    }
  }
}

# WARP Logging Configuration (optional)
resource "cloudflare_logpush_job" "warp_logs" {
  count            = var.enable_logs ? 1 : 0
  account_id       = var.account_id
  name             = "warp-logs"
  dataset          = "gateway_dns"
  destination_conf = "azure://${var.azure_storage_account}.blob.core.windows.net/${var.azure_storage_container}?${var.azure_sas_token}"
  enabled          = true
}