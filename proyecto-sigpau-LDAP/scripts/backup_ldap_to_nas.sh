#!/bin/bash
set -euo pipefail

# Configuración
NAS_MOUNT="/mnt/nas_backups"
FILE_NAME="backup_ldap_$(date +%F).ldif"
LOCAL_TMP="/tmp/$FILE_NAME"
NAS_DEST="$NAS_MOUNT/$FILE_NAME"
LOG="/var/log/backup_ldap_nas.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS_DB="FALLIDO"
STATUS_MSG="OK"

# Base de datos sigpau02
DB_HOST="10.120.22.207"
DB_USER="admin01"
DB_PASS="Asdqwe123"
DB_NAME="sigpau_mgmt"

echo "[$TIMESTAMP] === Iniciando backup LDAP al NAS ===" >> "$LOG"

# 1. Asegurar conexión al NAS
ip route add 10.1.100.17 via 10.120.17.200 dev enp0s3 2>/dev/null || true

# 2. Generar el volcado de la base de datos LDAP
if slapcat -n 1 -l "$LOCAL_TMP" 2>> "$LOG"; then
    # 3. Copiar al NAS
    if cp "$LOCAL_TMP" "$NAS_DEST" 2>> "$LOG"; then
        STATUS_DB="EXITOSO"
        echo "[$TIMESTAMP] Backup LDAP copiado con éxito al NAS." >> "$LOG"
    else
        STATUS_MSG="ERROR"
        echo "[$TIMESTAMP] ERROR: Fallo al copiar LDIF al NAS. Comprueba el montaje de red." >> "$LOG"
    fi
else
    STATUS_MSG="ERROR"
    echo "[$TIMESTAMP] ERROR: Fallo al ejecutar slapcat." >> "$LOG"
fi

# 4. Registrar auditoría en MariaDB (sigpau02)
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO backup_logs (fecha, archivo, destino, estado) VALUES ('$TIMESTAMP', 'sigpau01:$FILE_NAME', 'NAS:$NAS_DEST', '$STATUS_DB');" 2>> "$LOG" || echo "[$TIMESTAMP] WARN: No se pudo registrar en MariaDB" >> "$LOG"

echo "[$TIMESTAMP] === Backup finalizado: $STATUS_MSG ===" >> "$LOG"
