#!/bin/bash

# Script para instalar y configurar Google Authenticator (2FA) en Debian

set -e

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando la instalación de Google Authenticator 2FA...${NC}"

# 1. Verificar si el usuario es root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: Este script debe ejecutarse como root (usa sudo).${NC}"
  exit 1
fi

# 2. Actualizar repositorios e instalar el paquete
echo -e "${GREEN}Instalando libpam-google-authenticator...${NC}"
apt update && apt install -y libpam-google-authenticator

# 3. Configurar PAM para SSH
PAM_FILE="/etc/pam.d/sshd"
if ! grep -q "pam_google_authenticator.so" "$PAM_FILE"; then
    echo -e "${GREEN}Configurando PAM...${NC}"
    # Añadir al final del archivo o después de common-auth
    echo "auth required pam_google_authenticator.so" >> "$PAM_FILE"
else
    echo -e "${YELLOW}PAM ya está configurado para Google Authenticator.${NC}"
fi

# 4. Configurar SSH (sshd_config)
SSH_CONFIG="/etc/ssh/sshd_config"
echo -e "${GREEN}Configurando SSH...${NC}"

# Asegurar que KbdInteractiveAuthentication esté en yes
if grep -q "^KbdInteractiveAuthentication" "$SSH_CONFIG"; then
    sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' "$SSH_CONFIG"
else
    echo "KbdInteractiveAuthentication yes" >> "$SSH_CONFIG"
fi

# Para versiones más antiguas (Debian 10/11) que usan ChallengeResponseAuthentication
if grep -q "^ChallengeResponseAuthentication" "$SSH_CONFIG"; then
    sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' "$SSH_CONFIG"
else
    echo "ChallengeResponseAuthentication yes" >> "$SSH_CONFIG"
fi

# Asegurar que UsePAM esté en yes
if grep -q "^UsePAM" "$SSH_CONFIG"; then
    sed -i 's/^UsePAM.*/UsePAM yes/' "$SSH_CONFIG"
else
    echo "UsePAM yes" >> "$SSH_CONFIG"
fi

# 5. Reiniciar el servicio SSH
echo -e "${GREEN}Reiniciando el servicio SSH...${NC}"
systemctl restart ssh

echo -e "${GREEN}¡Instalación y configuración básica completadas!${NC}"
echo -e "${YELLOW}-------------------------------------------------------${NC}"
echo -e "Para finalizar la configuración, cada usuario debe ejecutar:"
echo -e "${RED}google-authenticator${NC}"
echo -e "Sigue las instrucciones en pantalla para escanear el código QR."
echo -e "${YELLOW}-------------------------------------------------------${NC}"
# Opción: Forzar 2FA incluso con llaves SSH (Opcional)
# echo "AuthenticationMethods publickey,keyboard-interactive" >> "$SSH_CONFIG"

echo -e "${RED}AVISO IMPORTANTE:${NC} No cierres tu sesión actual de SSH hasta que"
echo -e "hayas verificado que puedes entrar con una nueva conexión. Si usas llaves SSH"
echo -e "y quieres que también pida el código 2FA, deberás añadir la línea:"
echo -e "'AuthenticationMethods publickey,keyboard-interactive' al final de $SSH_CONFIG"
echo -e "y reiniciar SSH de nuevo."
