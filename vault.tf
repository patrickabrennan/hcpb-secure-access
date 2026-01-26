# If you don't already have a KV v1 mount at "kv", set create_kv_mount=true and include this block.

resource "vault_mount" "kv" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path
  type        = "kv" # KV v1 (flat data) for Boundary RDP credentials
  description = "KV v1 for Boundary RDP credentials"
}

# Write a flat secret (username/password) so Boundary can map it to credential_type = "username_password"
resource "vault_generic_secret" "rdp_admin" {
  path = "${var.vault_kv_mount_path}/${var.vault_kv_secret_path}" # e.g., "kv/boundary/rdp/svc"

  data_json = jsonencode({
    username = "Administrator"
    password = local.admin_password
  })
}



/*
# If you don't already have a KV v2 mount at "kv", set create_kv_mount=true and include this block.

resource "vault_mount" "kv" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path
  type        = "kv-v2"
  description = "KV v2 for Boundary RDP credentials"
}

resource "vault_kv_secret_v2" "rdp_admin" {
  mount = var.vault_kv_mount_path      # e.g., "kv"
  name  = var.vault_kv_secret_path     # e.g., "boundary/rdp/svc"

  data_json = jsonencode({
    username = "Administrator"
    password = local.admin_password
  })
}
*/
