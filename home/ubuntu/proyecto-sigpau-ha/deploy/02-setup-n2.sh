#!/bin/bash
# Configuración inicial Nodo 02

# 1. Asignar ServerID
cat <<LDIF | ldapmodify -Y EXTERNAL -H ldapi:///
dn: cn=config
changetype: modify
add: olcServerID
olcServerID: 2
LDIF

# 2. Configurar Syncrepl (apuntando a NODO01)
cat <<LDIF | ldapmodify -Y EXTERNAL -H ldapi:///
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncrepl
olcSyncrepl: {0}rid=001\n  provider=ldap://10.120.17.242:389\n  type=refreshAndPersist\n  retry=\"5 5 300 +\"\n  searchbase=\"dc=sigpau,dc=local\"\n  bindmethod=simple\n  binddn=\"cn=admin,dc=sigpau,dc=local\"\n  credentials=Asdqwe123
LDIF

# 3. Activar MirrorMode
cat <<LDIF | ldapmodify -Y EXTERNAL -H ldapi:///
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcMirrorMode
olcMirrorMode: TRUE
LDIF

# 4. Cargar Módulo SyncProv (para que también pueda ser proveedor)
cat <<LDIF | ldapmodify -Y EXTERNAL -H ldapi:///
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov
LDIF

# 5. Activar Overlay SyncProv
cat <<LDIF | ldapadd -Y EXTERNAL -H ldapi:///
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpCheckpoint: 100 10
olcSpSessionlog: 100
LDIF
