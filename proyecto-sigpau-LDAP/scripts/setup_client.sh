#!/bin/bash
# Script de configuración del Cliente Debian (Autenticación LDAP y Autofs)
# Este script configura un cliente para autenticarse contra el clúster LDAP de alta disponibilidad
# y para montar automáticamente los homes ("Perfiles Móviles") mediante NFS.

echo ">>> Instalando dependencias..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nslcd libpam-ldapd nfs-common autofs

# Eliminar paquete obsoleto/conflictivo de configuraciones pasadas con Samba/AD
echo ">>> Purgando dependencias conflictivas (libpam-mount)..."
apt-get remove --purge -y libpam-mount

echo ">>> Configurando NSLCD (Failover entre nodos LDAP)..."
# Recuperamos la credencial desde vault
VAULT_BIND_PW=$(vault kv get -field=password secret/sigpau/ldap)

# Usamos EOF sin comillas para evaluar la variable
cat > /etc/nslcd.conf << EOF
threads 8
uid nslcd
gid nslcd
uri ldap://10.120.17.242
uri ldap://10.120.22.207
base dc=sigpau,dc=local
binddn cn=admin,dc=sigpau,dc=local
bindpw $VAULT_BIND_PW
scope sub
EOF

echo ">>> Configurando Name Service Switch (/etc/nsswitch.conf)..."
sed -i 's/^passwd:.*$/passwd:         files systemd ldap sss/g' /etc/nsswitch.conf
sed -i 's/^group:.*$/group:          files systemd ldap sss/g' /etc/nsswitch.conf
sed -i 's/^shadow:.*$/shadow:         files systemd ldap sss/g' /etc/nsswitch.conf

echo ">>> Configurando PAM para auto-creación de home (mkhomedir)..."
pam-auth-update --force --enable mkhomedir ldap

echo ">>> Configurando Autofs (NFS Failover para Homes)..."
if ! grep -q "/home/ldap-users /etc/auto.home" /etc/auto.master; then
    echo "/home/ldap-users /etc/auto.home --timeout=300" >> /etc/auto.master
fi

cat > /etc/auto.home << 'EOF'
* -fstype=nfs,rw,soft,intr,rsize=8192,wsize=8192 10.120.17.242:/home/ldap-users/& 10.120.22.207:/home/ldap-users/&
EOF

echo ">>> Reiniciando servicios..."
systemctl restart nslcd
systemctl restart autofs

echo ">>> Configuración completada. Los usuarios LDAP ya pueden iniciar sesión."
