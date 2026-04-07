# ============================================================
# vault-config.hcl — Configuración de producción para Vault
# ============================================================

ui = true

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 1   # Cambiar a 0 en producción con certificados TLS
  # tls_cert_file = "/vault/certs/vault.crt"
  # tls_key_file  = "/vault/certs/vault.key"
}

storage "file" {
  path = "/vault/data"
}

api_addr = "http://0.0.0.0:8200"

# Política de auditoría — registra todos los accesos
# audit {
#   type = "file"
#   path = "/vault/logs/audit.log"
# }

# Tiempo de vida de los tokens
default_lease_ttl = "768h"    # 32 días
max_lease_ttl     = "8760h"   # 1 año
