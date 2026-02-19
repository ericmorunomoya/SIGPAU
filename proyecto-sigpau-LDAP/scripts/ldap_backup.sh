#!/bin/bash
# Script de Backup SIGPAU con Auditoría en MariaDB

FECHA=$(date +%Y%m%d_%H%M)
BACKUP_NAME="ldap_backup_$FECHA.ldif"
DESTINO_NAS="/mnt/nas_backups"
DB_HOST="10.120.22.207"
DB_USER="admin01"
DB_PASS="Sigpau2026*"

# 1. Exportar LDAP
/usr/sbin/slapcat -l /tmp/$BACKUP_NAME

# 2. Mover al NAS
if [ -s "/tmp/$BACKUP_NAME" ]; then
    cp /tmp/$BACKUP_NAME $DESTINO_NAS/$BACKUP_NAME
    [ -f "$DESTINO_NAS/$BACKUP_NAME" ] && STATUS="EXITOSO" || STATUS="FALLIDO"
    rm /tmp/$BACKUP_NAME
else
    STATUS="FALLIDO"
fi

# 3. Registrar en MariaDB
mysql --connect-timeout=5 -h $DB_HOST -u $DB_USER -p"$DB_PASS" sigpau_mgmt <<SQL
INSERT INTO backup_logs (fecha, archivo, destino, estado) 
VALUES (NOW(), '$BACKUP_NAME', 'NAS-SIGPAU', '$STATUS');
SQL
