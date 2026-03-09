#!/bin/bash

# Script interactivo mejorado para crear usuarios en LDAP (sigpau.local)
# Detecta automáticamente el siguiente UID y GID disponible.

echo "------------------------------------------------"
echo "   CREACIÓN DE USUARIO INTERACTIVO LDAP (AUTO-ID)"
echo "------------------------------------------------"

# 1. Detección automática de UID y GID
echo "Buscando IDs disponibles en el sistema..."

# Buscamos el UID más alto en LDAP. Si no hay, empezamos en 20000.
MAX_UID=$(ldapsearch -Q -Y EXTERNAL -H ldapi:/// -LLL -b "dc=sigpau,dc=local" "(objectClass=posixAccount)" uidNumber 2>/dev/null | grep uidNumber | cut -d' ' -f2 | sort -n | tail -1)
if [ -z "$MAX_UID" ]; then 
    # Si falla LDAP, probamos con getent (usuarios locales + ldap si están integrados)
    MAX_UID=$(getent passwd | cut -d: -f3 | sort -n | tail -1)
fi
NEXT_UID=$((MAX_UID + 1))

# Buscamos el GID más alto
MAX_GID=$(ldapsearch -Q -Y EXTERNAL -H ldapi:/// -LLL -b "dc=sigpau,dc=local" "(objectClass=posixAccount)" gidNumber 2>/dev/null | grep gidNumber | cut -d' ' -f2 | sort -n | tail -1)
if [ -z "$MAX_GID" ]; then 
    MAX_GID=$(getent group | cut -d: -f3 | sort -n | tail -1)
fi
NEXT_GID=$((MAX_GID + 1))

# 2. Recolección de datos
echo "Siguiente UID sugerido: $NEXT_UID"
echo "Siguiente GID sugerido: $NEXT_GID"
echo ""

read -p "Nombre (ej. Juan): " NOMBRE
read -p "Apellido (ej. Perez): " APELLIDO
read -p "Nombre de usuario (UID, ej. jperez): " USER_ID

# Ofrecemos los valores automáticos pero permitimos sobrescribirlos
read -p "UID Number [Enter para $NEXT_UID]: " UID_P
UID_NUM=${UID_P:-$NEXT_UID}

read -p "GID Number [Enter para $NEXT_GID]: " GID_P
GID_NUM=${GID_P:-$NEXT_GID}

read -s -p "Contraseña para el usuario: " PASSWORD
echo ""

FULL_NAME="$NOMBRE $APELLIDO"
BASE_DN="dc=sigpau,dc=local"
USER_DN="uid=$USER_ID,ou=people,$BASE_DN"

# 3. Creación del archivo LDIF temporal
LDIF_FILE="/tmp/new_user_$USER_ID.ldif"

cat <<EOF > $LDIF_FILE
dn: $USER_DN
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $USER_ID
sn: $APELLIDO
cn: $FULL_NAME
displayName: $FULL_NAME
uidNumber: $UID_NUM
gidNumber: $GID_NUM
userPassword: $PASSWORD
gecos: $FULL_NAME
loginShell: /bin/bash
homeDirectory: /home/$USER_ID
EOF

echo "Generando archivo LDIF en $LDIF_FILE..."

# 4. Intentar añadir al LDAP
echo "Intentando añadir usuario al directorio..."
ldapadd -Q -Y EXTERNAL -H ldapi:/// -f $LDIF_FILE

if [ $? -eq 0 ]; then
    echo "✅ Usuario $USER_ID creado exitosamente con UID:$UID_NUM y GID:$GID_NUM."
    
    # Crear el directorio home si no existe
    if [ ! -d "/home/$USER_ID" ]; then
        echo "Creando directorio home en /home/$USER_ID..."
        mkdir -p /home/$USER_ID
        chown $UID_NUM:$GID_NUM /home/$USER_ID
        chmod 700 /home/$USER_ID
    fi
else
    echo "❌ Error al crear el usuario. Revisa los datos o permisos."
fi

# 5. Limpieza
rm -f $LDIF_FILE
echo "------------------------------------------------"
