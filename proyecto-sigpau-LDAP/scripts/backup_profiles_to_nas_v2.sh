#!/bin/bash
set -euo pipefail

# Configuración
NAS_IP="10.1.100.17"
NAS_MOUNT="/mnt/nas_backups"
NAS_DEST="$NAS_MOUNT/profiles_ldap"
SOURCE="/home/ldap-users/"
LOG="/var/log/backup_profiles_nas.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS="OK"
ERROR_MSG=""

# Base de datos sigpau02
DB_HOST="10.120.22.207"
DB_USER="admin01"
DB_PASS=$(vault kv get -field=password secret/sigpau/db)
DB_NAME="sigpau_mgmt"

echo "[$TIMESTAMP] === Iniciando backup de perfiles al NAS (NFS) ===" >> "$LOG"

# 1. Asegurar que la ruta al NAS existe por la IP correcta (failover de red)
ip route add 10.1.100.17 via 10.120.17.200 dev enp0s3 2>/dev/null || true

# 2. Intentar montar el NAS vía NFS si no lo está
if ! mountpoint -q "$NAS_MOUNT"; then
    mount -t nfs "$NAS_IP:/export/backups_ldap" "$NAS_MOUNT" 2>> "$LOG" || {
        echo "[$TIMESTAMP] ERROR: No se pudo montar el NAS vía NFS en $NAS_MOUNT" >> "$LOG"
        STATUS="ERROR"
        ERROR_MSG="NFS mount failed"
    }
fi

# 3. Sincronización con rsync
if [ "$STATUS" = "OK" ]; then
    mkdir -p "$NAS_DEST"
    rsync -avz --delete "$SOURCE" "$NAS_DEST/" >> "$LOG" 2>&1 || {
        echo "[$TIMESTAMP] ERROR: Fallo durante rsync." >> "$LOG"
        STATUS="ERROR"
        ERROR_MSG="rsync failed"
    }
    
    if [ "$STATUS" = "OK" ]; then
        echo "[$TIMESTAMP] Backup completado con éxito." >> "$LOG"
    fi
fi

# 4. Registrar auditoría en MariaDB (sigpau02)
# Usando mysql -p con espacio si es preferido por el cliente, aunque el estándar es -pPASS
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO backup_log (timestamp, source, destination, status, error_message, type) VALUES ('$TIMESTAMP', 'sigpau01:$SOURCE', 'NAS:$NAS_DEST', '$STATUS', '$ERROR_MSG', 'profile_sync');" 2>> "$LOG" || echo "[$TIMESTAMP] WARN: No se pudo registrar en MariaDB ($DB_NAME)" >> "$LOG"

echo "[$TIMESTAMP] === Backup finalizado: $STATUS ===" >> "$LOG"
