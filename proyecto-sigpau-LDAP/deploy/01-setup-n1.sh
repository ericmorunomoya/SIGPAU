#!/bin/bash
# Configuración inicial Nodo 01

# 1. Asignar ServerID
cat <<LDIF | ldapmodify -Y EXTERNAL -H ldapi:///
dn: cn=config
changetype: modify
add: olcServerID
olcServerID: 1
LDIF

# 2. Cargar Módulo SyncProv
cat <<LDIF | ldapmodify -Y EXTERNAL -H ldapi:///
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov
LDIF

# 3. Activar Overlay
cat <<LDIF | ldapadd -Y EXTERNAL -H ldapi:///
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpCheckpoint: 100 10
olcSpSessionlog: 100
LDIF
