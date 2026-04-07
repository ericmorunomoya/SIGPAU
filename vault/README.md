# ============================================================
# vault/ — Gestión centralizada de secretos con HashiCorp Vault
# ============================================================

## ¿Qué hace esta carpeta?

Contiene la infraestructura para levantar **HashiCorp Vault** como gestor de secretos del proyecto SIGPAU. 
Elimina todas las contraseñas hardcodeadas de los scripts, reemplazándolas por llamadas dinámicas a la API de Vault.

## Arquitectura

```
vault/
├── docker-compose.yml  # Levanta Vault + inicialización automática de secretos
├── vault-config.hcl    # Configuración del servidor Vault
├── vault-init.sh       # Script para cargar secretos manualmente
└── .env.example        # Plantilla de variables (copiar a .env y rellenar)
```

## Secretos gestionados

| Path en Vault               | Descripción                        |
|-----------------------------|------------------------------------|
| `secret/sigpau/db`          | Contraseña base de datos SIGPAU    |
| `secret/sigpau/ldap`        | Contraseña admin LDAP              |
| `secret/sigpau/ssh`         | Contraseña SSH nodos               |
| `secret/sigpau/nas`         | Contraseña SMB del NAS             |
| `secret/sigpau/default_user`| Contraseña usuarios por defecto    |
| `secret/sigpau/grafana`     | Contraseña panel Grafana           |

## Uso rápido (servidor con Docker)

```bash
# 1. Copiar y rellenar .env
cp .env.example .env
nano .env

# 2. Levantar Vault
docker compose up -d

# 3. Verificar que Vault responde
curl http://localhost:8200/v1/sys/health
```

## Uso rápido (servidor sin Docker — ya instalado en sigpau01)

```bash
# Vault ya corre como servicio en 10.120.17.242:8200
systemctl status vault

# Extraer una contraseña desde cualquier script
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='sigpau-root-token'
vault kv get -field=password secret/sigpau/db
```

## Cómo los scripts usan Vault

En lugar de:
```bash
DB_PASS="Asdqwe123"   # ❌ Hardcodeado
```

Ahora hacen:
```bash
DB_PASS=$(vault kv get -field=password secret/sigpau/db)   # ✅ Seguro
```

> **Nota de seguridad**: El token `sigpau-root-token` es de desarrollo. 
> En producción, usar tokens con TTL y políticas de mínimo privilegio.
