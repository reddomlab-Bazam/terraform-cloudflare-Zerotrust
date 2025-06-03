# Cloudflare Zero Trust Infrastructure

A comprehensive Terraform configuration for deploying Cloudflare Zero Trust with Azure AD integration, designed for Red Team vs Blue Team security training environments.

## 🏗️ Infrastructure Overview

This configuration deploys a complete Zero Trust security framework including:

- **🔐 Access Control**: Team-based application access with Azure AD integration
- **🛡️ Gateway Protection**: DNS filtering, content blocking, and security policies
- **🔒 Device Security**: Microsoft Intune integration for device posture checks
- **🌐 WARP Client**: Secure device connectivity with team-specific policies
- **📊 Monitoring**: Integrated Wazuh and Grafana dashboards
- **🚇 Secure Tunnels**: Cloudflare tunnels for internal service exposure

## 📁 Project Structure

```
terraform/
├── environments/
│   └── prod/
│       ├── main.tf              # Main configuration
│       ├── variables.tf         # Variable definitions
│       ├── outputs.tf           # Output definitions
│       └── terraform.tfvars     # Variable values (create this)
└── modules/
    ├── access/                  # Access applications and policies
    ├── device_posture/          # Device compliance rules
    ├── gateway/                 # Network security policies
    ├── idp/                     # Identity provider configuration
    └── warp/                    # WARP client policies
```

## 🚀 Quick Start

### Prerequisites

1. **Cloudflare Account** with Zero Trust enabled
2. **Azure AD/Entra ID** tenant with administrative access
3. **Microsoft Intune** subscription (optional, for device posture)
4. **Terraform Cloud** account (recommended)

### Step 1: Clone and Configure

```bash
git clone <repository-url>
cd terraform/environments/prod
```

### Step 2: Create Variable Files

Create `terraform.tfvars`:
```hcl
# Cloudflare Configuration
account_id = "your-cloudflare-account-id"
api_token  = "your-cloudflare-api-token"

# Domain Configuration (change for different customers)
domain = "yourdomain.com"  # Must be managed by Cloudflare

# Azure AD Configuration
azure_client_id     = "your-azure-app-client-id"
azure_client_secret = "your-azure-app-secret"
azure_directory_id  = "your-azure-tenant-id"

# Microsoft Intune Configuration (optional)
intune_client_id     = "your-intune-app-client-id"
intune_client_secret = "your-intune-app-secret"

# Team Configuration
red_team_name = "Red Team"
blue_team_name = "Blue Team"
red_team_group_ids = ["azure-ad-group-id-for-red-team"]
blue_team_group_ids = ["azure-ad-group-id-for-blue-team"]

# Monitoring Domains (auto-generated from base domain)
wazuh_domain = "wazuh.yourdomain.com"
grafana_domain = "grafana.yourdomain.com"
```

### Step 3: Set Up Terraform Cloud (Recommended)

1. Create workspace: `terraform-cloudflare-zerotrust`
2. Configure variables in Terraform Cloud:

#### Environment Variables (Sensitive):
```bash
TF_VAR_api_token = "your-cloudflare-api-token"
TF_VAR_azure_client_secret = "your-azure-app-secret"
TF_VAR_intune_client_secret = "your-intune-app-secret"
```

#### Terraform Variables:
```hcl
domain = "yourdomain.com"
account_id = "your-cloudflare-account-id"
azure_client_id = "your-azure-app-client-id"
azure_directory_id = "your-azure-tenant-id"
red_team_group_ids = ["group-id-1"]
blue_team_group_ids = ["group-id-2"]
```

### Step 4: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file=terraform.tfvars

# Apply configuration
terraform apply -var-file=terraform.tfvars
```

## 🔧 Azure AD Setup

### Required Azure AD Applications

Create two Azure AD applications:

#### 1. Cloudflare Zero Trust Application
```bash
# Application settings:
Name: "Cloudflare Zero Trust"
Redirect URIs: https://<your-team-name>.cloudflareaccess.com/cdn-cgi/access/callback
Grant admin consent for Directory.Read.All
```

#### 2. Microsoft Intune Application (Optional)
```bash
# Application settings:
Name: "Cloudflare Intune Integration"
API Permissions: 
  - DeviceManagementManagedDevices.Read.All
  - DeviceManagementConfiguration.Read.All
```

### Required Azure AD Groups

Create security groups for team access:
```bash
# Red Team Group
Name: "Red Team Security"
Type: Security
Members: Add red team members

# Blue Team Group  
Name: "Blue Team Defense"
Type: Security
Members: Add blue team members
```

## 🌐 Domain Setup

### Add Domain to Cloudflare

1. **Add Site**: Go to Cloudflare dashboard → Add Site → Enter your domain
2. **Update Nameservers**: Update your domain registrar with Cloudflare nameservers
3. **Verify Setup**: Ensure domain shows "Active" status in Cloudflare

### Required DNS Records

The following subdomains will be automatically configured:
```bash
redteam.yourdomain.com     # Red Team application
blueteam.yourdomain.com    # Blue Team application  
wazuh.yourdomain.com       # Wazuh security platform
grafana.yourdomain.com     # Grafana monitoring
```

## 🧪 Testing Scenarios

### Test 1: Basic Access Control
```bash
# Verify team application access
curl -I https://redteam.yourdomain.com
curl -I https://blueteam.yourdomain.com

# Expected: 302 redirect to Azure AD login
```

### Test 2: Device Posture Compliance
```bash
# Install WARP client on test device
# Navigate to: https://redteam.yourdomain.com/warp
# Follow enrollment process
# Verify device compliance in Cloudflare dashboard
```

### Test 3: DNS Filtering
```bash
# Test malicious domain blocking
nslookup malware-domain.com 1.1.1.1

# Expected: Blocked by Cloudflare security filtering
```

### Test 4: Tunnel Connectivity
```bash
# Test internal service access
curl -I https://wazuh.yourdomain.com
curl -I https://grafana.yourdomain.com

# Expected: 302 redirect to authentication
```

### Test 5: Team Isolation
```bash
# Login as Red Team member
# Attempt access to: https://blueteam.yourdomain.com
# Expected: Access denied

# Login as Blue Team member  
# Attempt access to: https://redteam.yourdomain.com
# Expected: Access denied
```

## 📊 Monitoring and Outputs

After successful deployment, you'll get these outputs:

```hcl
application_urls = {
  "blue_team" = "https://blueteam.yourdomain.com"
  "grafana" = "https://grafana.yourdomain.com"
  "red_team" = "https://redteam.yourdomain.com"
  "wazuh" = "https://wazuh.yourdomain.com"
}

monitoring_tunnel_id = "fd6c1246-a5bb-4d4c-bba2-63ddde86ddcf"
warp_enrollment_url = "https://redteam.yourdomain.com/warp"
```

## 🔄 Multi-Environment Setup

### For Different Customers/Environments

1. **Create New Workspace**: `terraform-cloudflare-customer-a`
2. **Update Variables**:
   ```hcl
   domain = "customer-a.com"
   red_team_group_ids = ["customer-a-red-team-group"]
   blue_team_group_ids = ["customer-a-blue-team-group"]
   ```
3. **Deploy**: `terraform apply`

### For Development/Staging

```hcl
# Use subdomains for environments
domain = "dev.yourdomain.com"
# or
domain = "staging.yourdomain.com"
```

## 🛠️ Customization

### Adding New Applications

1. **Add to access module** (`modules/access/main.tf`):
```hcl
resource "cloudflare_zero_trust_access_application" "new_app" {
  account_id = var.account_id
  name       = "New Application"
  domain     = "newapp.${var.domain}"
  type       = "self_hosted"
  session_duration = "8h"
}
```

2. **Add access policy**:
```hcl
resource "cloudflare_zero_trust_access_policy" "new_app_access" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.new_app.id
  name           = "New App Access Policy"
  decision       = "allow"
  precedence     = 1

  include {
    group = [var.red_team_group_id, var.blue_team_group_id]
  }
}
```

### Custom Gateway Policies

Add to `modules/gateway/main.tf`:
```hcl
resource "cloudflare_zero_trust_gateway_policy" "custom_policy" {
  account_id  = var.account_id
  name        = "Custom Security Policy"
  description = "Block specific categories"
  precedence  = 15
  action      = "block"
  filters     = ["dns"]
  traffic     = "any(dns.content_category[*] in {1 4 5})"
  enabled     = true
}
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Domain Not Managed by Cloudflare
```bash
Error: domain does not belong to zone (12130)
```
**Solution**: Add domain to Cloudflare and update nameservers

#### 2. DNS Filter Syntax Error
```bash
Error: Filter parsing error
```
**Solution**: Use correct syntax: `any(dns.domains[*] in {"domain.com"})`

#### 3. Azure AD Permission Issues
```bash
Error: insufficient privileges
```
**Solution**: Grant admin consent for required API permissions

#### 4. Device Posture Integration Failed
```bash
Error: Intune integration failed
```
**Solution**: Verify Intune app permissions and tenant configuration

### Debug Commands

```bash
# Check Terraform state
terraform state list

# View specific resource
terraform state show module.access.cloudflare_zero_trust_access_application.red_team

# Force refresh
terraform refresh -var-file=terraform.tfvars

# Targeted apply
terraform apply -target=module.access -var-file=terraform.tfvars
```

## 🔐 Security Best Practices

### Variable Management
- ✅ Use Terraform Cloud for sensitive variables
- ✅ Never commit secrets to Git
- ✅ Use environment variables for API tokens
- ✅ Enable variable encryption in Terraform Cloud

### Access Control
- ✅ Implement least privilege access
- ✅ Regular review of group memberships
- ✅ Enable MFA for all accounts
- ✅ Monitor access logs regularly

### Network Security
- ✅ Enable all security categories in Gateway
- ✅ Regular review of gateway policies
- ✅ Monitor DNS query logs
- ✅ Implement device posture requirements

## 📋 Production Checklist

Before deploying to production:

- [ ] Domain added to Cloudflare and active
- [ ] Azure AD applications configured with correct permissions
- [ ] Security groups created with proper membership
- [ ] Terraform Cloud workspace configured
- [ ] All sensitive variables marked as sensitive
- [ ] Backup of current configuration
- [ ] Test deployment in non-production environment
- [ ] Team training on new access procedures
- [ ] Incident response plan updated
- [ ] Monitoring and alerting configured

## 📞 Support

### Infrastructure Issues
- Check Terraform Cloud run logs
- Review Cloudflare Zero Trust dashboard
- Verify Azure AD application configuration

### Access Issues
- Verify user group membership in Azure AD
- Check device compliance status
- Review access policy configuration

### Network Issues
- Test DNS resolution
- Check gateway policy precedence
- Verify tunnel connectivity

## 🔄 Updates and Maintenance

### Regular Tasks
- **Weekly**: Review access logs and security alerts
- **Monthly**: Update device posture policies
- **Quarterly**: Review and update security policies
- **Annually**: Rotate API tokens and secrets

### Version Updates
```bash
# Update Terraform modules
terraform init -upgrade

# Plan with new versions
terraform plan -var-file=terraform.tfvars

# Apply updates
terraform apply -var-file=terraform.tfvars
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**🎯 Ready to deploy secure, scalable Zero Trust infrastructure!**