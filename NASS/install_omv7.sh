#!/bin/bash

# Script para instalar OpenMediaVault 7 (Sandworm)
# Este script debe ejecutarse como root

# Colores para la salida
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando la instalación de OpenMediaVault 7...${NC}"

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
  echo "Por favor, ejecuta este script como root o con sudo."
  exit 1
fi

# 1. Instalar y configurar systemd-resolved
echo -e "${GREEN}Instalando y configurando systemd-resolved...${NC}"
apt-get update
apt-get install --yes systemd-resolved
systemctl enable systemd-resolved
systemctl start systemd-resolved

# Configuración de DNS temporal (ajusta INTERFACE y DNS_SERVER_IP si es necesario)
# Por defecto intentaremos detectar la interfaz principal
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
DNS_SERVER_IP="8.8.8.8" # DNS de Google como predeterminado para la instalación

if [ -n "$INTERFACE" ]; then
    echo -e "${GREEN}Configurando DNS temporalmente en la interfaz $INTERFACE...${NC}"
    resolvectl dns "$INTERFACE" "$DNS_SERVER_IP"
else
    echo "No se pudo detectar la interfaz de red automáticamente. Saltando configuración de DNS temporal."
fi

# 2. Añadir el repositorio de OMV
echo -e "${GREEN}Añadiendo el repositorio de OpenMediaVault...${NC}"
apt-get install --yes gnupg
wget --quiet -O - https://packages.openmediavault.org/public/archive.key \
  | gpg --dearmor --yes \
  > /usr/share/keyrings/openmediavault-archive-keyring.gpg

cat <<EOF > /etc/apt/sources.list.d/openmediavault.list
deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] \
https://packages.openmediavault.org/public sandworm main
EOF

# 3. Instalar OMV
echo -e "${GREEN}Instalando OpenMediaVault (esto puede tardar un poco)...${NC}"
export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

apt-get update
apt-get --yes --auto-remove --show-upgraded \
  --allow-downgrades --allow-change-held-packages \
  --no-install-recommends \
  --option DPkg::Options::="--force-confdef" \
  --option DPkg::Options::="--force-confold" \
  install openmediavault

# 4. Inicializar la base de datos de OMV
echo -e "${GREEN}Inicializando la base de datos de OMV...${NC}"
omv-confdbadm populate

echo -e "${GREEN}¡Instalación completada con éxito!${NC}"
echo "Puedes acceder a la interfaz web de OMV a través de la dirección IP de este servidor."
