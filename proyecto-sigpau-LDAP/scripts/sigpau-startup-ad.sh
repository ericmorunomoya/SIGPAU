#!/bin/bash
# SIGPAU Services Persistency Script - AD SERVER
# Generado por Red Neuronal Alejabot
LOG="/var/log/sigpau-startup.log"
echo "[$(date)] Sincronizando servicios SIGPAU..." >> $LOG

# 1. Asegurar slapd (OpenLDAP)
systemctl start slapd
sleep 2

# 2. Asegurar samba-ad-dc
systemctl start samba-ad-dc

# 3. Asegurar panel web
if ! pgrep -f panel.py > /dev/null; then
    echo "[$(date)] Levantando Panel de Control..." >> $LOG
    nohup python3 /opt/sigpau-panel/panel.py > /opt/sigpau-panel/panel.log 2>&1 &
fi

echo "[$(date)] Infraestructura AD activa y sincronizada." >> $LOG
