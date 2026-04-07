#!/bin/bash
# ============================================================
# vault-init.sh — Inicializa los secretos de SIGPAU en Vault
# Ejecutar UNA VEZ tras arrancar el servidor de Vault.
# Requiere: VAULT_ADDR y VAULT_TOKEN exportados.
# ============================================================

set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-sigpau-root-token}"

export VAULT_ADDR VAULT_TOKEN

echo "🔐 Conectando a Vault en $VAULT_ADDR..."
vault status

echo ""
echo "📦 Habilitando motor KV-v2..."
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "  (ya habilitado)"

echo ""
echo "📝 Cargando secretos SIGPAU..."
vault kv put secret/sigpau/db           password="${DB_PASS:-CAMBIAR}"
vault kv put secret/sigpau/ldap         password="${LDAP_ADMIN_PASS:-CAMBIAR}"
vault kv put secret/sigpau/ssh          password="${SSH_PASS:-CAMBIAR}"
vault kv put secret/sigpau/nas          password="${NAS_SMB_PASS:-CAMBIAR}"
vault kv put secret/sigpau/default_user password="${DEFAULT_USER_PASS:-CAMBIAR}"
vault kv put secret/sigpau/grafana      password="${GRAFANA_PASS:-CAMBIAR}"

echo ""
echo "✅ Secretos cargados. Verificando..."
vault kv list secret/sigpau
