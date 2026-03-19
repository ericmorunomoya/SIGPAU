# Infraestructura de Alta Disponibilidad SIGPAU (Samba4 + OpenLDAP)

Este repositorio contiene la configuración completa y documentada para desplegar un dominio **NT4-Style** con Alta Disponibilidad, utilizando **OpenLDAP** con replicación **MirrorMode** y **Samba 4** como PDC/BDC.

## 🚀 Características Principales
- **OpenLDAP Multi-Master:** Sincronización bidireccional entre Nodo01 y Nodo02.
- **Samba PDC/BDC:** Gestión de identidades compatible con Windows 10/11.
- **SSSD Multi-Dominio:** Autenticación simultánea desde Samba AD y OpenLDAP en clientes Debian.
- **Perfiles Móviles:** Almacenamiento centralizado en NAS (SMB/CIFS) para escritorios portables.
- **RAID 5 en NAS:** Almacenamiento redundante con 4 discos (2.7 TB útiles) para los homes.
- **Auditoría de Backups:** Scripts automatizados con registro en base de datos MariaDB.
- **Seguridad:** Configuración de SIDs unificados y permisos avanzados (Sticky Bit).
- **Control Center:** Panel web interactivo End-to-End con métricas en vivo y reportes en PDF.

## 📂 Estructura del Proyecto
- `conf/samba/`: Configuración de Samba (smb.conf).
- `conf/sssd/`: Configuración de SSSD, Kerberos y PAM para doble dominio.
- `conf/ldap/`: Configuración de OpenLDAP.
- `conf/mariadb/`: Configuración de MariaDB.
- `deploy/`: Archivos LDIF y scripts para el despliegue inicial.
- `docs/`: Guías detalladas paso a paso.
- `panel/`: **SIGPAU Control Center** (Dashboard web Flask).
- `scripts/`: Herramientas de mantenimiento y backups.

## 🖥️ Arquitectura
| Servidor | IP | Función |
|----------|-----|---------|
| Samba AD / OpenLDAP | 10.120.17.242 | DC + LDAP (puertos 389/3389) |
| NAS | 10.1.100.17 | Homes RAID 5 (2.7 TB) |
| Cliente Debian | 10.120.17.247 | Nodo con SSSD multi-dominio |

## 🛠️ Requisitos del Sistema
- **OS:** Ubuntu 22.04 / Debian 12.
- **Sincronización NTP:** Crítico para la replicación LDAP.
- **Red:** Puertos 389 (Samba LDAP), 3389 (OpenLDAP), 445/139 (Samba), 88 (Kerberos), 3306 (MariaDB).

## 👥 Autores
- **Experto en Sistemas:** Configuración y Arquitectura.
- **Linus Torvalds (Role):** Organización y Estructura.
