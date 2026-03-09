#!/bin/bash

# Script interactivo para borrar usuarios en LDAP (sigpau.local)
# Ejecutar como root o con permisos sobre LDAP

echo "------------------------------------------------"
echo "   BORRADO DE USUARIO INTERACTIVO LDAP"
echo "------------------------------------------------"

BASE_DN="dc=sigpau,dc=local"

# 1. Mostrar usuarios actuales para facilitar el borrado
echo "Usuarios actuales en el sistema:"
ldapsearch -Q -Y EXTERNAL -H ldapi:/// -LLL -b "$BASE_DN" "(objectClass=posixAccount)" uid cn 2>/dev/null | grep -E "uid:|cn:" | sed 's/uid: /  - /' | sed 's/cn: / (/' | sed 's/$/)/'
echo ""

# 2. Solicitar UID a borrar
read -p "Introduce el UID (nombre de usuario) que deseas BORRAR: " USER_ID

if [ -z "$USER_ID" ]; then
    echo "❌ No has introducido ningún usuario. Abortando."
    exit 1
fi

# 3. Verificar si el usuario existe y obtener DN completo
USER_DN=$(ldapsearch -Q -Y EXTERNAL -H ldapi:/// -LLL -b "$BASE_DN" "(uid=$USER_ID)" dn 2>/dev/null | grep dn: | cut -d' ' -f2)

if [ -z "$USER_DN" ]; then
    echo "❌ El usuario '$USER_ID' no existe en LDAP."
    exit 1
fi

echo "Se va a borrar permanentemente: $USER_DN"
read -p "¿Estás seguro? (s/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[sS]$ ]]; then
    echo "Operación cancelada por el usuario."
    exit 0
fi

# 4. Borrar de LDAP
echo "Borrando entrada de LDAP..."
ldapdelete -Q -Y EXTERNAL -H ldapi:/// "$USER_DN"

if [ $? -eq 0 ]; then
    echo "✅ Entrada de LDAP borrada correctamente."
    
    # 5. Borrar home directory (opcional)
    if [ -d "/home/$USER_ID" ]; then
        read -p "¿Deseas borrar también el directorio /home/$USER_ID? (s/N): " BORRAR_HOME
        if [[ "$BORRAR_HOME" =~ ^[sS]$ ]]; then
            echo "Borrando /home/$USER_ID..."
            rm -rf "/home/$USER_ID"
            echo "✅ Directorio home borrado."
        else
            echo "Se ha mantenido el directorio home."
        fi
    fi
else
    echo "❌ Error al borrar el usuario de LDAP."
fi

echo "------------------------------------------------"
