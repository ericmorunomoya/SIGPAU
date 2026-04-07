#!/bin/bash
set -euo pipefail

# Configuración
NAS_IP="10.1.100.17"
NAS_MOUNT="/mnt/nas_backups"
NAS_DEST="$NAS_MOUNT/profiles_ldap"
SOURCE="/home/ldap-users/"
LOG="/var/log/backup_profiles_nas.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS_DB="FALLIDO"
STATUS_MSG="OK"

# Base de datos sigpau02
DB_HOST="10.120.22.207"
DB_USER="admin01"
DB_PASS=$(vault kv get -field=password secret/sigpau/db)
DB_NAME="sigpau_mgmt"

echo "[$TIMESTAMP] === Iniciando backup de perfiles al NAS (NFS) ===" >> "$LOG"

# 1. Asegurar ruta al NAS
ip route add 10.1.100.17 via 10.120.17.200 dev enp0s3 2>/dev/null || true

# 2. Intentar montar el NAS vía NFS
if ! mountpoint -q "$NAS_MOUNT"; then
    mount -t nfs "$NAS_IP:/export/backups_ldap" "$NAS_MOUNT" 2>> "$LOG" || STATUS_MSG="ERROR"
fi

if [ "$STATUS_MSG" = "OK" ]; then
    mkdir -p "$NAS_DEST"
    rsync -avz --delete "$SOURCE" "$NAS_DEST/" >> "$LOG" 2>&1
    if [ $? -eq 0 ]; then
        STATUS_DB="EXITOSO"
        echo "[$TIMESTAMP] Backup completado con éxito." >> "$LOG"
    else
        STATUS_MSG="ERROR"
        echo "[$TIMESTAMP] ERROR: Fallo durante rsync." >> "$LOG"
    fi
fi

# 4. Registrar auditoría en MariaDB (sigpau02) - Schema: id, fecha, archivo, destino, estado
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO backup_logs (fecha, archivo, destino, estado) VALUES ('$TIMESTAMP', 'sigpau01:$SOURCE', 'NAS:$NAS_DEST', '$STATUS_DB');" 2>> "$LOG" || echo "[$TIMESTAMP] WARN: No se pudo registrar en MariaDB" >> "$LOG"

echo "[$TIMESTAMP] === Backup finalizado: $STATUS_MSG ===" >> "$LOG"
