#!/bin/bash
# SIGPAU Services Persistency Script - CLIENT DEBIAN
# Generado por Red Neuronal Alejabot
LOG="/var/log/sigpau-startup.log"
echo "[$(date)] Sincronizando servicios CLIENTE SIGPAU..." >> $LOG

# 1. Asegurar SSSD
systemctl start sssd

echo "[$(date)] Cliente SIGPAU activo y sincronizado." >> $LOG
