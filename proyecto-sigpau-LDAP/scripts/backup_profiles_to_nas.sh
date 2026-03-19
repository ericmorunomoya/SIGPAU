#!/bin/bash
set -euo pipefail

NAS_IP="10.1.100.17"
NAS_MOUNT="/mnt/nas_backups"
NAS_DEST="$NAS_MOUNT/profiles_ldap"
SOURCE="/home/ldap-users/"
LOG="/var/log/backup_profiles_nas.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS="OK"
ERROR_MSG=""

echo "[$TIMESTAMP] === Iniciando backup de perfiles al NAS (vía NFS) ===" >> "$LOG"

# Asegurar que el NAS esté montado vía NFS
if ! mountpoint -q "$NAS_MOUNT"; then
    mount -t nfs "$NAS_IP:/export/backups_ldap" "$NAS_MOUNT" 2>> "$LOG" || {
        echo "[$TIMESTAMP] ERROR: No se pudo montar el NAS vía NFS." >> "$LOG"
        STATUS="ERROR"
        ERROR_MSG="NFS mount failed"
    }
fi

if [ "$STATUS" = "$OK" ] || [ "$STATUS" = "OK" ]; then
    mkdir -p "$NAS_DEST"
    rsync -avz --delete "$SOURCE" "$NAS_DEST/" >> "$LOG" 2>&1
    if [ $? -eq 0 ]; then
        echo "[$TIMESTAMP] Backup completado exitosamente." >> "$LOG"
    else
        echo "[$TIMESTAMP] ERROR durante rsync." >> "$LOG"
        STATUS="ERROR"
        ERROR_MSG="rsync failed"
    fi
fi

# Registrar en MariaDB
mysql -h 10.120.22.207 -u admin01 -pAsdqwe123 management -e "INSERT INTO backup_log (timestamp, source, destination, status, error_message, type) VALUES ('$TIMESTAMP', 'sigpau01:$SOURCE', 'NAS:$NAS_DEST', '$STATUS', '$ERROR_MSG', 'profile_sync');" 2>> "$LOG" || echo "[$TIMESTAMP] WARN: No se pudo registrar en MariaDB" >> "$LOG"

echo "[$TIMESTAMP] === Backup finalizado: $STATUS ===" >> "$LOG"
