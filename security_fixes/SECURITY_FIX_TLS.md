# 🔐 Guía de Actualización: Certificado TLS Obsoleto — SIGPAU

El sistema SIGPAU ha reportado un problema de seguridad por certificados TLS obsoletos. Esto suele deberse al uso de algoritmos de firma débiles (**SHA-1**) o protocolos antiguos (**TLS 1.1**). Esta guía detalla cómo regenerar los certificados del servidor LDAP (sigpau01) y propagarlos.

## 🛠️ Procedimiento de Actualización (SHA-256)

### 1. Generar nueva Autoridad de Certificación (CA) Interna
Es necesario elevar la seguridad a **RSA 4096 / SHA-256**.
```bash
# Generamos la llave privada de la CA
openssl genrsa -out /etc/ldap/ssl/sigpau-ca.key 4096

# Creamos el certificado raíz (Válido por 10 años para estabilidad)
openssl req -x509 -new -nodes -key /etc/ldap/ssl/sigpau-ca.key -sha256 -days 3650 -out /etc/ldap/ssl/sigpau-ca.crt -subj "/C=ES/ST=BCN/L=Barcelona/O=SIGPAU/CN=SIGPAU-Root-CA"
```

### 2. Generar Certificado para el Servidor (sigpau01)
```bash
# Llave privada del servidor
openssl genrsa -out /etc/ldap/ssl/ldap-server.key 2048

# Certificate Signing Request (CSR)
openssl req -new -key /etc/ldap/ssl/ldap-server.key -out /etc/ldap/ssl/ldap-server.csr -subj "/C=ES/ST=BCN/L=Barcelona/O=SIGPAU/CN=sigpau01.sigpau.local"

# Firmar con nuestra CA (SHA-256)
openssl x509 -req -in /etc/ldap/ssl/ldap-server.csr -CA /etc/ldap/ssl/sigpau-ca.crt -CAkey /etc/ldap/ssl/sigpau-ca.key -CAcreateserial -out /etc/ldap/ssl/ldap-server.crt -days 730 -sha256
```

### 3. Aplicar en OpenLDAP (LDIF)
Una vez generados los archivos en `/etc/ldap/ssl/`, aplicamos el cambio dinámico:
```ldif
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/ssl/sigpau-ca.crt
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/ssl/ldap-server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/ssl/ldap-server.key
```
**Comando**: `sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f certs_new.ldif`

## 🛡️ Hardening de Protocolo (Deshabilitar TLS Obsoleto)
Para forzar el uso de solo **TLS 1.2+**, añadimos la siguiente configuración al `cn=config`:
```ldif
dn: cn=config
changetype: modify
add: olcTLSProtocolMin
olcTLSProtocolMin: 3.3
```
*(Nota: 3.3 corresponde a TLS 1.2)*

## 🔄 Propagación Crucial
1.  **Copiar `sigpau-ca.crt` a sigpau02 y al Cliente Debian.**
2.  Importar en el almacén de confianza: `sudo cp sigpau-ca.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`.
3.  Reiniciar servicios: `systemctl restart slapd` (en servidores) y `systemctl restart nslcd` (en clientes).
