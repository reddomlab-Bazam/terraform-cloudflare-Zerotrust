variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "intune_client_id" {
  description = "Microsoft Intune Client ID for ZTNAPostureChecks app"
  type        = string
  default     = ""
}

variable "intune_client_secret" {
  description = "Microsoft Intune Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_tenant_id" {
  description = "Azure AD Tenant ID for Intune integration"
  type        = string
  default     = ""
}

# Enhanced security variables
variable "corporate_certificate_id" {
  description = "Corporate certificate ID for certificate-based device validation"
  type        = string
  default     = ""
}

variable "corporate_domain" {
  description = "Corporate domain name for domain join validation"
  type        = string
  default     = ""
}

variable "allowed_serial_numbers" {
  description = "List of allowed device serial numbers for additional security"
  type        = list(string)
  default     = []
}

variable "minimum_os_versions" {
  description = "Minimum OS versions required for different platforms"
  type = object({
    windows = string
    macos   = string
    linux   = string
  })
  default = {
    windows = "10.0.19044"  # Windows 10 21H2
    macos   = "12.0.0"      # macOS Monterey
    linux   = "20.04"       # Ubuntu 20.04 LTS
  }
}

variable "security_software_requirements" {
  description = "Required security software and minimum versions"
  type = map(object({
    name           = string
    minimum_version = string
    required       = bool
  }))
  default = {
    defender = {
      name           = "Microsoft Defender"
      minimum_version = "4.18.0"
      required       = true
    }
  }
}

variable "compliance_check_frequency" {
  description = "Frequency for compliance checks in minutes"
  type = object({
    antivirus       = string
    disk_encryption = string
    intune         = string
    firewall       = string
    os_version     = string
  })
  default = {
    antivirus       = "15m"
    disk_encryption = "30m"
    intune         = "15m"
    firewall       = "30m"
    os_version     = "6h"
  }
}