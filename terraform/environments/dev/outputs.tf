output "teams_account_id" {
  value = module.warp.teams_account_id
}

output "azure_idp_id" {
  value = cloudflare_zero_trust_access_identity_provider.azure_ad.id
}