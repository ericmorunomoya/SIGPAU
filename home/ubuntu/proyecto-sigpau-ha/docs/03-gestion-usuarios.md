# Gestión de Usuarios y Grupos

## Crear Unidades Organizativas
```ldif
dn: ou=people,dc=sigpau,dc=local
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=sigpau,dc=local
objectClass: organizationalUnit
ou: groups
```

## Añadir Usuario (Ejemplo: Eric)
```ldif
dn: uid=eric,ou=people,dc=sigpau,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: eric
sn: Eric
cn: Eric
uidNumber: 10003
gidNumber: 20000
homeDirectory: /mnt/nas_profiles/eric
loginShell: /bin/bash
userPassword: {SSHA}password_cifrada
```

## Vincular con Samba (SID)
Para que el usuario pueda loguearse en Windows:
```bash
pdbedit -a -u eric
```
