#!/bin/bash
# Script para inyectar el esquema de Samba en OpenLDAP

# Instalar dependencias
apt-get install -y schema2ldif samba

# Extraer esquema de Samba
zcat /usr/share/doc/samba/examples/LDAP/samba.schema.gz > /tmp/samba.schema

# Convertir a formato LDIF
schema2ldif -i /tmp/samba.schema -o /tmp/samba.ldif

# Inyectar en LDAP
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/samba.ldif

rm /tmp/samba.schema /tmp/samba.ldif
