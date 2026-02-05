#!/bin/bash
 
# --- Variables de Configuración ---
DB_HOST="10.120.22.207"
DB_USER="backup_user"
DB_PASS="CONTRASEÑA"
DB_NAME="SIGPAU"
NAS_USER="pau"
NAS_IP="10.1.100.17"
NAS_PATH="/volumen1/backups/mariadb" # Asegúrese de que esta ruta exista en el NAS
 
# --- Variables de Ejecución ---
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${DB_NAME}_${DATE}.sql.gz"
LOG_FILE="/var/log/db_backup.log"
 
# --- Inicio del Proceso ---
echo "--- Inicio del Backup: $(date) ---" >> $LOG_FILE
 
# 1. Exportar la DB y comprimir (mysqldump | gzip)
# 2. Transferir el flujo de datos comprimido directamente al NAS vía SSH
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS \
    --single-transaction --routines --triggers $DB_NAME | gzip | \
    ssh $NAS_USER@$NAS_IP "cat > ${NAS_PATH}/${BACKUP_FILE}" 2>> $LOG_FILE
 
# --- Verificación y Registro ---
if [ $? -eq 0 ]; then
    echo "Backup exitoso: ${BACKUP_FILE} transferido a $NAS_IP" >> $LOG_FILE
else
    echo "ERROR en el backup o transferencia. Revise el log." >> $LOG_FILE
fi
 
echo "--- Fin del Backup ---" >> $LOG_FILE
