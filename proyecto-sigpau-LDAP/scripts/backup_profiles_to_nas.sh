#!/bin/bash
# Script de backup de perfiles móviles al NAS con log en MariaDB

NAS_MOUNT="/mnt/nas_backups"
SOURCE_DIR="/home/ldap-users/"
DB_HOST="10.120.22.207"
DB_USER="root"
DB_PASS="Asdqwe123"
DB_NAME="management"

# 1. Asegurar montaje del NAS
if ! mountpoint -q "$NAS_MOUNT"; then
    mount -t cifs //10.1.100.17/RAID5 "$NAS_MOUNT" -o username=lautaro,password=Asdqwe123456789,uid=0,gid=0
fi

# 2. Ejecutar Rsync
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RSYNC_OUT=$(rsync -avz --delete "$SOURCE_DIR" "$NAS_MOUNT/profiles_backup/" 2>&1)
EXIT_CODE=$?

# 3. Registrar resultado en MariaDB
if [ $EXIT_CODE -eq 0 ]; then
    STATUS="OK"
    ERROR_MSG=""
else
    STATUS="ERROR"
    ERROR_MSG=$(echo "$RSYNC_OUT" | tail -n 1)
fi

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO backup_log (timestamp, source, destination, status, error_message, type) VALUES ('$TIMESTAMP', 'sigpau01', 'NAS-RAID5', '$STATUS', '$ERROR_MSG', 'User Profiles');"
