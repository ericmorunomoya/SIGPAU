#!/bin/bash

# -----------------------------
# Configuración del bot (RECUERDA USAR UN TOKEN NUEVO)
# -----------------------------
TOKEN="7754937907:AAEmXOHagArEXAh163TZ8QlxJvUJLeKP1J8"
CHAT_ID="835463082"
LOG_FILE="/tmp/telegram_alerts.log"
HOSTNAME=$(hostname)  # Capturamos el nombre de la máquina

# -----------------------------
# Lista de servicios críticos
# -----------------------------
SERVICES=(
    "php7.4-fpm"
    "mariadb"
    "smbd"
    "slapd"
    "apache2"
    "nginx"
    "zabbix-server"
    "ssh"
)

# Emojis para el estado
UP="✅"
DOWN="❌"

# -----------------------------
# Construir mensaje con el Hostname
# -----------------------------
STATUS_MSG="🖥️ Estado de servicios importantes
📍 Servidor: $HOSTNAME
----------------------------
"

CRITICAL=0  # Contador de servicios caídos

for svc in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc"; then
        STATUS_MSG+="$UP $svc
"
    else
        STATUS_MSG+="$DOWN $svc
"
        ((CRITICAL++))
    fi
done

# Determinar severidad
if [ $CRITICAL -eq 0 ]; then
    SEVERITY="Information"
else
    SEVERITY="High"
fi

# -----------------------------
# Enviar mensaje a Telegram
# -----------------------------
TEXT="$STATUS_MSG"

RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    --data-urlencode "chat_id=$CHAT_ID" \
    --data-urlencode "text=$TEXT" \
    -o /tmp/telegram_curl.log -w "%{http_code}")

# -----------------------------
# Registrar errores si falla
# -----------------------------
if [ "$RESPONSE" != "200" ]; then
    echo "$(date) - ERROR al enviar Telegram: HTTP $RESPONSE" >> "$LOG_FILE"
fi
# -----------------------------
if [ "$RESPONSE" != "200" ]; then
  echo "$(date) - ERROR al enviar Telegram: HTTP $RESPONSE" >> "$LOG_FILE"
fi
