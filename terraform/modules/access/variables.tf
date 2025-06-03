variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "app_name" {
  description = "Access Application Name"
  type        = string
}

variable "domain" {
  description = "Base domain managed by Cloudflare (e.g., reddomelab.com)"
  type        = string
  default     = "reddomelab.com"
}

variable "allowed_emails" {
  description = "List of allowed email addresses"
  type        = list(string)
  default     = []
}

variable "red_team_name" {
  description = "Name of the Red Team group"
  type        = string
  default     = "Red Team"
}

variable "blue_team_name" {
  description = "Name of the Blue Team group"
  type        = string
  default     = "Blue Team"
}

variable "red_team_id" {
  description = "ID of the Red Team rule group"
  type        = string
}

variable "blue_team_id" {
  description = "ID of the Blue Team rule group"
  type        = string
}

variable "red_team_group_ids" {
  description = "List of Azure AD group IDs for red team members"
  type        = list(string)
  default     = []
}

variable "blue_team_group_ids" {
  description = "List of Azure AD group IDs for blue team members"
  type        = list(string)
  default     = []
}

variable "device_posture_rule_ids" {
  description = "List of device posture rule IDs to require"
  type        = list(string)
  default     = []
}

variable "azure_ad_provider_id" {
  description = "ID of the Azure AD identity provider"
  type        = string
}

variable "red_team_app_domain" {
  description = "Domain for the Red Team application"
  type        = string
  default     = "redteam.reddomelab.com"
}

variable "blue_team_app_domain" {
  description = "Domain for the Blue Team application"
  type        = string
  default     = "blueteam.reddomelab.com"
}

variable "red_team_group_id" {
  description = "ID of the Red Team access group"
  type        = string
}

variable "blue_team_group_id" {
  description = "ID of the Blue Team access group"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

# Monitoring application domains
variable "wazuh_domain" {
  description = "Domain for Wazuh application"
  type        = string
  default     = "wazuh.reddomelab.com"
}

variable "grafana_domain" {
  description = "Domain for Grafana application"
  type        = string
  default     = "grafana.reddomelab.com"
}