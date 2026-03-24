#!/bin/bash
# ============================================================
# Script: update_sigpau_tls.sh
# Descripción: Automatiza la generación de CA y Certificados 
#              LDAP con SHA-256 (RSA 4096).
# Nodo: ExpertoProgramacion (Red Neuronal)
# ============================================================

set -euo pipefail

SSL_DIR="/etc/ldap/ssl"
DAYS=3650  # 10 años para la CA

echo "[*] Creando directorio de certificados: $SSL_DIR"
sudo mkdir -p "$SSL_DIR"
sudo chown root:openldap "$SSL_DIR"
sudo chmod 750 "$SSL_DIR"

# 1. Generar CA Raíz (SHA-256)
echo "[*] Generando Autoridad de Certificación (CA) Raíz..."
sudo openssl genrsa -out "$SSL_DIR/sigpau-ca.key" 4096
sudo openssl req -x509 -new -nodes -key "$SSL_DIR/sigpau-ca.key" \
    -sha256 -days "$DAYS" -out "$SSL_DIR/sigpau-ca.crt" \
    -subj "/C=ES/ST=BCN/L=Barcelona/O=SIGPAU/CN=SIGPAU-Root-CA"

# 2. Generar Certificado de Servidor
echo "[*] Generando Certificado de Servidor (sigpau01)..."
sudo openssl genrsa -out "$SSL_DIR/ldap-server.key" 2048
sudo openssl req -new -key "$SSL_DIR/ldap-server.key" \
    -out "$SSL_DIR/ldap-server.csr" \
    -subj "/C=ES/ST=BCN/L=Barcelona/O=SIGPAU/CN=sigpau01.sigpau.local"

echo "[*] Firmando certificado con la CA..."
sudo openssl x509 -req -in "$SSL_DIR/ldap-server.csr" \
    -CA "$SSL_DIR/sigpau-ca.crt" -CAkey "$SSL_DIR/sigpau-ca.key" \
    -CAcreateserial -out "$SSL_DIR/ldap-server.crt" \
    -days 730 -sha256

# Ajustar permisos
sudo chown root:openldap "$SSL_DIR"/*
sudo chmod 640 "$SSL_DIR"/*.key
sudo chmod 644 "$SSL_DIR"/*.crt

# 3. Generar LDIF de configuración
echo "[*] Creando archivo LDIF para aplicar los cambios..."
cat << EOF > /tmp/tls_update.ldif
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: $SSL_DIR/sigpau-ca.crt
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: $SSL_DIR/ldap-server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: $SSL_DIR/ldap-server.key
-
add: olcTLSProtocolMin
olcTLSProtocolMin: 3.3
EOF

echo "[*] Aplicando cambios en OpenLDAP (cn=config)..."
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/tls_update.ldif

echo "[*] Reiniciando servicio slapd..."
sudo systemctl restart slapd

echo "[OK] Actualización de TLS de SIGPAU finalizada exitosamente."
