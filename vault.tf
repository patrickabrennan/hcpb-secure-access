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
    username = ".\\Administrator"
    password = local.admin_password
  })
}
