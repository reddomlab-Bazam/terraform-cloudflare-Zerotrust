# Gateway Module: Manages Cloudflare Zero Trust Gateway policies and network security rules
# Simplified version compatible with Cloudflare provider 4.52.0

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Security Threat Blocking Policy
resource "cloudflare_zero_trust_gateway_policy" "security_blocks" {
  account_id = var.account_id
  name       = "Security Threat Blocks"
  precedence = 1
  action     = "block"
  enabled    = true
  description = "Blocks access to known malicious domains and content"

  filters = ["dns"]
  traffic = "any(dns.security_category[*] in {4 7 9 80})"
}

# Security Tools Access Policy
resource "cloudflare_zero_trust_gateway_policy" "security_tools" {
  account_id = var.account_id
  name       = "Security Tools Access"
  precedence = 2
  action     = "allow"
  enabled    = true
  description = "Allows access to approved security tools and resources"

  filters = ["dns"]
  traffic = "any(dns.domains[*] in {\"kali.org\" \"metasploit.com\" \"hackerone.com\" \"splunk.com\" \"elastic.co\" \"sentinelone.com\"})"
}

# Basic DNS Filtering Policy
resource "cloudflare_zero_trust_gateway_policy" "dns_filter" {
  account_id = var.account_id
  name       = "Basic DNS Filtering"
  precedence = 100
  action     = "allow"
  enabled    = true
  description = "Allow general DNS traffic"

  filters = ["dns"]
  traffic = "dns.domains[*] matches \".*\""
}