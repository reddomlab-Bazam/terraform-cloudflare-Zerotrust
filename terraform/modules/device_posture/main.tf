# Device Posture Module: Enhanced security compliance checks
# This module creates comprehensive device compliance rules and integrates with Microsoft Intune

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Microsoft Intune Integration for Device Posture
resource "cloudflare_zero_trust_device_posture_integration" "intune" {
  account_id = var.account_id
  name       = "Microsoft Intune"
  type       = "intune"
  interval   = "15m"  # More frequent checks for security
  config {
    client_id     = var.intune_client_id
    client_secret = var.intune_client_secret
    customer_id   = var.azure_tenant_id
  }
}

# Antivirus Check - Windows
resource "cloudflare_zero_trust_device_posture_rule" "antivirus_windows" {
  account_id  = var.account_id
  name        = "Antivirus Status Check - Windows"
  type        = "antivirus"
  description = "Checks if antivirus is enabled and up-to-date on Windows devices"
  schedule    = "15m"
  expiration  = "15m"
  match {
    platform = "windows"
  }
  input {
    operating_system    = "windows"
    require_all        = true
    check_private_key  = false
  }
  depends_on = [cloudflare_zero_trust_device_posture_integration.intune]
}

# Antivirus Check - macOS
resource "cloudflare_zero_trust_device_posture_rule" "antivirus_macos" {
  account_id  = var.account_id
  name        = "Antivirus Status Check - macOS"
  type        = "antivirus"
  description = "Checks if antivirus is enabled and up-to-date on macOS devices"
  schedule    = "15m"
  expiration  = "15m"
  match {
    platform = "mac"
  }
  input {
    operating_system    = "mac"
    require_all        = true
    check_private_key  = false
  }
  depends_on = [cloudflare_zero_trust_device_posture_integration.intune]
}

# Disk Encryption Rule - Windows (BitLocker)
resource "cloudflare_zero_trust_device_posture_rule" "disk_encryption_windows" {
  account_id = var.account_id
  name       = "BitLocker Encryption Check - Windows"
  type       = "disk_encryption"
  description = "Ensures BitLocker is enabled on all Windows drives"
  schedule   = "30m"
  expiration = "30m"
  match {
    platform = "windows"
  }
  input {
    check_disks = ["C:", "D:"]  # Check system and data drives
    require_all = true
  }
}

# Disk Encryption Rule - macOS (FileVault)
resource "cloudflare_zero_trust_device_posture_rule" "disk_encryption_macos" {
  account_id = var.account_id
  name       = "FileVault Encryption Check - macOS"
  type       = "disk_encryption"
  description = "Ensures FileVault is enabled on macOS devices"
  schedule   = "30m"
  expiration = "30m"
  match {
    platform = "mac"
  }
  input {
    check_disks = ["/"]
    require_all = true
  }
}

# OS Version Rule - Windows (Require Windows 10/11)
resource "cloudflare_zero_trust_device_posture_rule" "os_version_windows" {
  account_id = var.account_id
  name       = "OS Version Check - Windows"
  type       = "os_version"
  description = "Requires Windows 10 build 19044 or newer (Windows 11 compatible)"
  schedule   = "6h"
  expiration = "6h"
  match {
    platform = "windows"
  }
  input {
    version = "10.0.19044"  # Windows 10 21H2 or newer
    operator = ">="
  }
}

# OS Version Rule - macOS (Require macOS 12+)
resource "cloudflare_zero_trust_device_posture_rule" "os_version_macos" {
  account_id = var.account_id
  name       = "OS Version Check - macOS"
  type       = "os_version"
  description = "Requires macOS Monterey (12.0) or newer"
  schedule   = "6h"
  expiration = "6h"
  match {
    platform = "mac"
  }
  input {
    version = "12.0.0"
    operator = ">="
  }
}

# Intune Compliance Rule - Windows
resource "cloudflare_zero_trust_device_posture_rule" "intune_compliance_windows" {
  account_id = var.account_id
  name       = "Intune Compliance Check - Windows"
  type       = "intune"
  description = "Validates Windows device compliance through Microsoft Intune"
  schedule   = "15m"
  expiration = "15m"
  match {
    platform = "windows"
  }
  input {
    compliance_status = "compliant"
    connection_id     = cloudflare_zero_trust_device_posture_integration.intune.id
  }
}

# Intune Compliance Rule - macOS
resource "cloudflare_zero_trust_device_posture_rule" "intune_compliance_macos" {
  account_id = var.account_id
  name       = "Intune Compliance Check - macOS"
  type       = "intune"
  description = "Validates macOS device compliance through Microsoft Intune"
  schedule   = "15m"
  expiration = "15m"
  match {
    platform = "mac"
  }
  input {
    compliance_status = "compliant"
    connection_id     = cloudflare_zero_trust_device_posture_integration.intune.id
  }
}

# Firewall Check - Windows
resource "cloudflare_zero_trust_device_posture_rule" "firewall_windows" {
  account_id  = var.account_id
  name        = "Windows Firewall Check"
  description = "Ensures Windows Defender Firewall is enabled"
  type        = "firewall"
  schedule    = "30m"
  expiration  = "30m"
  match {
    platform = "windows"
  }
  input {
    enabled = true
  }
  depends_on = [cloudflare_zero_trust_device_posture_integration.intune]
}

# Firewall Check - macOS
resource "cloudflare_zero_trust_device_posture_rule" "firewall_macos" {
  account_id  = var.account_id
  name        = "macOS Firewall Check"
  description = "Ensures macOS firewall is enabled"
  type        = "firewall"
  schedule    = "30m"
  expiration  = "30m"
  match {
    platform = "mac"
  }
  input {
    enabled = true
  }
  depends_on = [cloudflare_zero_trust_device_posture_integration.intune]
}

# Certificate Check for Corporate Devices
resource "cloudflare_zero_trust_device_posture_rule" "certificate_check" {
  account_id  = var.account_id
  name        = "Corporate Certificate Check"
  description = "Validates presence of corporate certificate"
  type        = "certificate"
  schedule    = "24h"
  expiration  = "24h"
  match {
    platform = "windows"
  }
  input {
    certificate_id = var.corporate_certificate_id
    cn            = "*.reddome.org"
  }
  
  # Only check if certificate ID is provided
  count = var.corporate_certificate_id != "" ? 1 : 0
}

# Application Check - Security Software
resource "cloudflare_zero_trust_device_posture_rule" "security_software_check" {
  account_id  = var.account_id
  name        = "Required Security Software Check"
  description = "Ensures required security software is installed"
  type        = "application"
  schedule    = "1h"
  expiration  = "1h"
  match {
    platform = "windows"
  }
  input {
    application_id = "microsoft-defender"
    version       = "4.18.0"
    operator      = ">="
    enabled       = true
  }
}

# Domain Join Check (Optional - for hybrid environments)
resource "cloudflare_zero_trust_device_posture_rule" "domain_joined_check" {
  account_id  = var.account_id
  name        = "Corporate Domain Join Check"
  description = "Validates device is joined to corporate domain"
  type        = "domain_joined"
  schedule    = "24h"
  expiration  = "24h"
  match {
    platform = "windows"
  }
  input {
    domain = var.corporate_domain
  }
  
  # Only create if corporate domain is specified
  count = var.corporate_domain != "" ? 1 : 0
}

# Unique Device ID Check
resource "cloudflare_zero_trust_device_posture_rule" "device_serial_check" {
  account_id  = var.account_id
  name        = "Device Serial Number Check"
  description = "Validates device serial number for device identification"
  type        = "serial_number"
  schedule    = "24h"
  expiration  = "24h"
  match {
    platform = "windows"
  }
  input {
    serial_number = var.allowed_serial_numbers
  }
  
  # Only create if serial numbers are specified
  count = length(var.allowed_serial_numbers) > 0 ? 1 : 0
}