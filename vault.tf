# If you don't already have a KV v2 mount at "kv", set create_kv_mount=true and include this block.
variable "create_kv_mount" { 
  type = bool 
  default = false
}

variable "vault_kv_mount_path" {
  type = string
  default = "kv"
}

variable "vault_kv_secret_path" {
  type = string
  default = "boundary/rdp/svc"
}

resource "vault_mount" "kv" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path
  type        = "kv-v2"
  description = "KV v2 for Boundary RDP credentials"
}

resource "vault_kv_secret_v2" "rdp_admin" {
  mount = var.vault_kv_mount_path
  name  = var.vault_kv_secret_path

  # Boundary expects username/password — match the LOCAL account
  data_json = jsonencode({
    username = ".\\Administrator"
    password = local.admin_password
  })
}

# Your existing policy wiring is fine; if you prefer, keep it as-is:
# path "${var.vault_kv_mount_path}/data/${var.vault_kv_secret_path}" { capabilities=["read"] }
