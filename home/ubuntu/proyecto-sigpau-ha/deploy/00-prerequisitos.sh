#!/bin/bash
# Script de pre-requisitos para nodos LDAP/Samba

# Actualizar sistema
apt update && apt upgrade -y

# Instalar Chrony para sincronización NTP
apt install -y chrony
systemctl enable --now chronyd

# Configurar /etc/hosts (ejemplo, ajustar IPs según entorno)
cat <<HOSTS_EOF >> /etc/hosts
10.120.17.242 NODO01
10.120.22.207 NODO02
HOSTS_EOF

# Instalar herramientas LDAP y Samba
apt install -y slapd ldap-utils samba smbclient cifs-utils

# Configurar permisos para perfiles NAS
mkdir -p /mnt/nas_profiles
chmod 1777 /mnt/nas_profiles
