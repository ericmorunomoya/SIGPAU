#!/bin/bash

# -----------------------------
# Configuración
# -----------------------------
TOKEN="8509333409:AAGQEv_Q2P7L2H_BJw5iFDYxOYkll9iiX1A"           # Reemplaza con tu token nuevo
CHAT_ID="835463082"       # Reemplaza con tu chat ID fijo o usa {ALERT.SENDTO}
LOG_FILE="/tmp/telegram_alerts.log"  # Para registrar fallos

# -----------------------------
# Parámetros del script
# -----------------------------
SUBJECT="$1"
MESSAGE="$2"
SEVERITY="$3"   # Opcional, se puede pasar desde Zabbix

# -----------------------------
# Emojis según severidad
# -----------------------------
case "$SEVERITY" in
  "Disaster") EMOJI="🔴" ;;
  "High")     EMOJI="🟠" ;;
  "Average")  EMOJI="🟡" ;;
  "Warning")  EMOJI="🟢" ;;
  "Information") EMOJI="ℹ️" ;;
  *) EMOJI="📌" ;;
esac

# -----------------------------
# Preparar mensaje con Markdown
# -----------------------------
TEXT="$EMOJI *${SUBJECT}*
${MESSAGE}"

URL="https://api.telegram.org/bot$TOKEN/sendMessage"

# -----------------------------
# Enviar mensaje
# -----------------------------
RESPONSE=$(curl -s -X POST "$URL" \
  --data-urlencode "chat_id=$CHAT_ID" \
  --data-urlencode "text=$TEXT" \
  -o /tmp/telegram_curl.log -w "%{http_code}")

# -----------------------------
# Registro de errores
# -----------------------------
if [ "$RESPONSE" != "200" ]; then
  echo "$(date) - ERROR al enviar Telegram: HTTP $RESPONSE" >> "$LOG_FILE"
fi
