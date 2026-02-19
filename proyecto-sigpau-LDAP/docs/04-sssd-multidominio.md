# 04 - Configuración SSSD Multi-Dominio (AD + LDAP)

## Objetivo
Configurar SSSD en el cliente Debian para autenticar usuarios desde **dos fuentes simultáneamente**:
- **Samba AD** (`dc=sigpau,dc=lab`) → usuarios del dominio Active Directory
- **OpenLDAP** (`dc=sigpau,dc=local`) → usuarios del directorio LDAP

## Problema
En el servidor `10.120.17.242`, Samba AD y OpenLDAP coexisten. Samba ocupa el puerto 389 y exige TLS para binds simples, lo que bloquea la conexión directa de SSSD al OpenLDAP.

## Solución

### 1. Servidor LDAP/AD (10.120.17.242)

#### 1.1 Desactivar requisito de TLS para binds simples
Añadir en `/etc/samba/smb.conf` dentro de `[global]`:
```ini
ldap server require strong auth = no
```

#### 1.2 Activar slapd en puerto alternativo
slapd estaba enmascarado porque Samba usa el puerto 389. Se activa en puerto 3389:

```bash
# Desenmascar slapd
systemctl unmask slapd

# Configurar puerto 3389 en /etc/default/slapd
SLAPD_SERVICES="ldap://0.0.0.0:3389/ ldapi:///"

# Arrancar slapd
/usr/sbin/slapd -h 'ldap://0.0.0.0:3389/ ldapi:///' -u openldap -g openldap

# Habilitar al inicio
systemctl enable slapd
```

#### 1.3 Reiniciar Samba
```bash
systemctl restart samba-ad-dc
```

### 2. Cliente Debian (10.120.17.247)

#### 2.1 Instalar paquetes
```bash
apt install -y sssd sssd-tools libnss-sss libpam-sss ldap-utils krb5-user
```

#### 2.2 Configurar Kerberos (`/etc/krb5.conf`)
Ver archivo: `conf/sssd/krb5.conf`

#### 2.3 Configurar SSSD (`/etc/sssd/sssd.conf`)
Ver archivo: `conf/sssd/sssd.conf`
```bash
chmod 600 /etc/sssd/sssd.conf
```

#### 2.4 Configurar PAM
Reemplazar los archivos en `/etc/pam.d/`:
- `common-auth` → Ver `conf/sssd/common-auth`
- `common-session` → Ver `conf/sssd/common-session`

#### 2.5 Configurar NSSwitch (`/etc/nsswitch.conf`)
```
passwd:         files systemd sss
group:          files systemd sss
shadow:         files systemd sss
```

#### 2.6 Desactivar Winbind y activar SSSD
```bash
systemctl stop winbind
systemctl disable winbind
rm -f /var/lib/sss/db/*
systemctl restart sssd
systemctl enable sssd
```

### 3. Verificación
```bash
# Usuarios AD
getent passwd eric
getent passwd lautaro

# Usuarios LDAP
getent passwd josemota
getent passwd pablomotos
getent passwd matiasprats

# Login SSH
ssh josemota@10.120.17.247
ssh eric@10.120.17.247
```

## Resultado
| Usuario | Fuente | UID | Home |
|---------|--------|-----|------|
| eric | Samba AD | 10003 | `/mnt/nas_profiles/eric` |
| lautaro | Samba AD | 10001 | `/mnt/nas_profiles/lautaro` |
| josemota | OpenLDAP | 10004 | `/mnt/nas_profiles/josemota` |
| pablomotos | OpenLDAP | 10005 | `/mnt/nas_profiles/pablomotos` |
| matiasprats | OpenLDAP | 10006 | `/mnt/nas_profiles/matiasprats` |

## Puertos en el Servidor
| Puerto | Servicio |
|--------|----------|
| 389 | Samba AD (LDAP) |
| 636 | Samba AD (LDAPS) |
| 88 | Kerberos |
| 3389 | OpenLDAP (slapd) |
