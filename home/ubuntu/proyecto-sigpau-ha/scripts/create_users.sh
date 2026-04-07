#!/bin/bash
# Script para crear usuarios en LDAP y vincularlos con Samba

ADMIN_DN="cn=admin,dc=sigpau,dc=local"
ADMIN_PW=$(vault kv get -field=password secret/sigpau/ldap)


# Crear Unidad Organizativa 'people' si no existe
ldapadd -x -D "$ADMIN_DN" -w "$ADMIN_PW" <<LDIF
dn: ou=people,dc=sigpau,dc=local
objectClass: organizationalUnit
ou: people
LDIF

# Crear Unidad Organizativa 'groups' si no existe
ldapadd -x -D "$ADMIN_DN" -w "$ADMIN_PW" <<LDIF
dn: ou=groups,dc=sigpau,dc=local
objectClass: organizationalUnit
ou: groups
LDIF

# Crear grupo 'admins' si no existe
ldapadd -x -D "$ADMIN_DN" -w "$ADMIN_PW" <<LDIF
dn: cn=admins,ou=groups,dc=sigpau,dc=local
objectClass: posixGroup
cn: admins
gidNumber: 20000
LDIF

# Mapear grupos de Samba (si no existen)
net groupmap add ntgroup="Domain Admins" unixgroup="admins" rid=512 type=d
net groupmap add ntgroup="Domain Users" unixgroup="users" rid=513 type=d

# Función para añadir usuario
add_user() {
    UID=$1
    SN=$2
    CN=$3
    UID_NUMBER=$4
    GID_NUMBER=$5
    PASSWORD=$6

    # Añadir usuario a LDAP
    ldapadd -x -D "$ADMIN_DN" -w "$ADMIN_PW" <<LDIF
dn: uid=$UID,ou=people,dc=sigpau,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $UID
sn: $SN
cn: $CN
uidNumber: $UID_NUMBER
gidNumber: $GID_NUMBER
homeDirectory: /mnt/nas_profiles/$UID
loginShell: /bin/bash
userPassword: $(slappasswd -s $PASSWORD)
LDIF

    # Vincular con Samba
    (echo "$PASSWORD"; echo "$PASSWORD") | pdbedit -a -u $UID
}

USER_PW=$(vault kv get -field=password secret/sigpau/default_user)

# Añadir usuarios
add_user lautaro ApellidoLautaro Lautaro 10001 10000 "$USER_PW"
add_user pau ApellidoPau Pau 10002 10000 "$USER_PW"
add_user eric ApellidoEric Eric 10003 10000 "$USER_PW"
add_user josemota Mota JoseMota 10004 10000 "$USER_PW"
add_user pablomotos Motos PabloMotos 10005 10000 "$USER_PW"
add_user matiasprats Prats MatiasPrats 10006 10000 "$USER_PW"

# Añadir Lautaro, Pau y Eric al grupo de administradores
ldapmodify -x -D "$ADMIN_DN" -w "$ADMIN_PW" <<LDIF
dn: cn=admins,ou=groups,dc=sigpau,dc=local
changetype: modify
add: memberUid
memberUid: lautaro
memberUid: pau
memberUid: eric
LDIF

echo "Usuarios creados y vinculados con Samba."
