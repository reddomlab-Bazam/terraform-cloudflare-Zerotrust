# Since we removed the teams_account resource, update the outputs
output "teams_account_id" {
  value = var.account_id
}

output "teams_name" {
  value = var.warp_name
}