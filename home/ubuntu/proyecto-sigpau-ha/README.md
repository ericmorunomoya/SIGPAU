# Infraestructura de Alta Disponibilidad SIGPAU (Samba4 + OpenLDAP)

Este repositorio contiene la configuración completa y documentada para desplegar un dominio **NT4-Style** con Alta Disponibilidad, utilizando **OpenLDAP** con replicación **MirrorMode** y **Samba 4** como PDC/BDC.

## 🚀 Características Principales
- **OpenLDAP Multi-Master:** Sincronización bidireccional entre Nodo01 y Nodo02.
- **Samba PDC/BDC:** Gestión de identidades compatible con Windows 10/11.
- **Perfiles Móviles:** Almacenamiento centralizado en NAS (SMB/CIFS) para escritorios portables.
- **Auditoría de Backups:** Scripts automatizados con registro en base de datos MariaDB.
- **Seguridad:** Configuración de SIDs unificados y permisos avanzados (Sticky Bit).

## 📂 Estructura del Proyecto
- `conf/`: Archivos de configuración para Samba, LDAP y MariaDB.
- `deploy/`: Archivos LDIF y scripts para el despliegue inicial.
- `docs/`: Guías detalladas de configuración de clientes y gestión.
- `scripts/`: Herramientas de mantenimiento y backups.

## 🛠️ Requisitos del Sistema
- **OS:** Ubuntu 22.04 LTS (o similar).
- **Sincronización NTP:** Crítico para la replicación LDAP.
- **Red:** Conectividad en puertos 389 (LDAP), 445/139 (Samba), 3306 (MariaDB).

## 👥 Autores
- **Experto en Sistemas:** Configuración y Arquitectura.
- **Linus Torvalds (Role):** Organización y Estructura.
