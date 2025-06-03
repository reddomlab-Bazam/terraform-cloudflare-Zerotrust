# Antivirus Rule Outputs
output "antivirus_rule_id_windows" {
  description = "ID of the Windows antivirus posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.antivirus_windows.id
}

output "antivirus_rule_id_macos" {
  description = "ID of the macOS antivirus posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.antivirus_macos.id
}

# Disk Encryption Rule Outputs
output "disk_encryption_rule_id_windows" {
  description = "ID of the Windows disk encryption posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.disk_encryption_windows.id
}

output "disk_encryption_rule_id_macos" {
  description = "ID of the macOS disk encryption posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.disk_encryption_macos.id
}

# OS Version Rule Outputs
output "os_version_rule_id_windows" {
  description = "ID of the Windows OS version posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.os_version_windows.id
}

output "os_version_rule_id_macos" {
  description = "ID of the macOS OS version posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.os_version_macos.id
}

# Intune Compliance Rule Outputs
output "intune_compliance_rule_id_windows" {
  description = "ID of the Windows Intune compliance posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.intune_compliance_windows.id
}

output "intune_compliance_rule_id_macos" {
  description = "ID of the macOS Intune compliance posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.intune_compliance_macos.id
}

# Firewall Rule Outputs
output "firewall_rule_id_windows" {
  description = "ID of the Windows firewall posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.firewall_windows.id
}

output "firewall_rule_id_macos" {
  description = "ID of the macOS firewall posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.firewall_macos.id
}

# Certificate Check Output (conditional)
output "certificate_rule_id" {
  description = "ID of the certificate posture rule"
  value       = var.corporate_certificate_id != "" ? cloudflare_zero_trust_device_posture_rule.certificate_check[0].id : null
}

# Security Software Check Output
output "security_software_rule_id" {
  description = "ID of the security software posture rule"
  value       = cloudflare_zero_trust_device_posture_rule.security_software_check.id
}

# Domain Join Check Output (conditional)
output "domain_joined_rule_id" {
  description = "ID of the domain joined posture rule"
  value       = var.corporate_domain != "" ? cloudflare_zero_trust_device_posture_rule.domain_joined_check[0].id : null
}

# Device Serial Check Output (conditional)
output "device_serial_rule_id" {
  description = "ID of the device serial number posture rule"
  value       = length(var.allowed_serial_numbers) > 0 ? cloudflare_zero_trust_device_posture_rule.device_serial_check[0].id : null
}

# Intune Integration Output
output "intune_integration_id" {
  description = "ID of the Intune device posture integration"
  value       = cloudflare_zero_trust_device_posture_integration.intune.id
}

# Consolidated lists for easy consumption
output "all_posture_rule_ids" {
  description = "List of all device posture rule IDs for use in access policies"
  value = compact([
    cloudflare_zero_trust_device_posture_rule.antivirus_windows.id,
    cloudflare_zero_trust_device_posture_rule.antivirus_macos.id,
    cloudflare_zero_trust_device_posture_rule.disk_encryption_windows.id,
    cloudflare_zero_trust_device_posture_rule.disk_encryption_macos.id,
    cloudflare_zero_trust_device_posture_rule.os_version_windows.id,
    cloudflare_zero_trust_device_posture_rule.os_version_macos.id,
    cloudflare_zero_trust_device_posture_rule.intune_compliance_windows.id,
    cloudflare_zero_trust_device_posture_rule.intune_compliance_macos.id,
    cloudflare_zero_trust_device_posture_rule.firewall_windows.id,
    cloudflare_zero_trust_device_posture_rule.firewall_macos.id,
    cloudflare_zero_trust_device_posture_rule.security_software_check.id,
    var.corporate_certificate_id != "" ? cloudflare_zero_trust_device_posture_rule.certificate_check[0].id : null,
    var.corporate_domain != "" ? cloudflare_zero_trust_device_posture_rule.domain_joined_check[0].id : null,
    length(var.allowed_serial_numbers) > 0 ? cloudflare_zero_trust_device_posture_rule.device_serial_check[0].id : null
  ])
}

# Platform-specific rule collections
output "windows_posture_rule_ids" {
  description = "List of Windows-specific posture rule IDs"
  value = compact([
    cloudflare_zero_trust_device_posture_rule.antivirus_windows.id,
    cloudflare_zero_trust_device_posture_rule.disk_encryption_windows.id,
    cloudflare_zero_trust_device_posture_rule.os_version_windows.id,
    cloudflare_zero_trust_device_posture_rule.intune_compliance_windows.id,
    cloudflare_zero_trust_device_posture_rule.firewall_windows.id,
    cloudflare_zero_trust_device_posture_rule.security_software_check.id,
    var.corporate_certificate_id != "" ? cloudflare_zero_trust_device_posture_rule.certificate_check[0].id : null,
    var.corporate_domain != "" ? cloudflare_zero_trust_device_posture_rule.domain_joined_check[0].id : null,
    length(var.allowed_serial_numbers) > 0 ? cloudflare_zero_trust_device_posture_rule.device_serial_check[0].id : null
  ])
}

output "macos_posture_rule_ids" {
  description = "List of macOS-specific posture rule IDs"
  value = [
    cloudflare_zero_trust_device_posture_rule.antivirus_macos.id,
    cloudflare_zero_trust_device_posture_rule.disk_encryption_macos.id,
    cloudflare_zero_trust_device_posture_rule.os_version_macos.id,
    cloudflare_zero_trust_device_posture_rule.intune_compliance_macos.id,
    cloudflare_zero_trust_device_posture_rule.firewall_macos.id
  ]
}

# Security-focused rule collections
output "critical_security_rule_ids" {
  description = "List of critical security posture rule IDs (antivirus, encryption, compliance)"
  value = [
    cloudflare_zero_trust_device_posture_rule.antivirus_windows.id,
    cloudflare_zero_trust_device_posture_rule.antivirus_macos.id,
    cloudflare_zero_trust_device_posture_rule.disk_encryption_windows.id,
    cloudflare_zero_trust_device_posture_rule.disk_encryption_macos.id,
    cloudflare_zero_trust_device_posture_rule.intune_compliance_windows.id,
    cloudflare_zero_trust_device_posture_rule.intune_compliance_macos.id
  ]
}