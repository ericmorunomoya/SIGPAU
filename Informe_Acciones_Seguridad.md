# Informe de Acciones de Seguridad Implementadas

**Proyecto:** SIGPAU
**Fecha:** 27 de Abril de 2026

## 1. Identificación y Remediación de Contraseñas Harcodeadas
Durante la revisión del repositorio se detectaron contraseñas en texto plano, tanto para cuentas maestras de infraestructura (LDAP, SSH, bases de datos) como en scripts de despliegue. 
- **Acción:** Se han eliminado por completo las contraseñas escritas en texto plano (`Asdqwe123`, así como la clave intermedia utilizada en la actualización) de **todos los archivos** del repositorio.
- **Archivos saneanizados:**
  - `home/ubuntu/proyecto-sigpau-ha/scripts/create_users.sh`
  - `home/ubuntu/proyecto-sigpau-ha/deploy/02-setup-n2.sh`
  - `home/ubuntu/proyecto-sigpau-ha/deploy/02-ldap-consumer.ldif`
  - `Auditorias/Reporte_Auditoria_Pentesting.html`
  - `Politicas_Seguridad.md`
- **Sustitución:** En su lugar se han implementado marcadores de posición (`<LDAP_ADMIN_PASSWORD>`, `<CONTRASEÑA_OCULTA>`, etc.) indicando que las variables deben ser proporcionadas a través de entornos seguros, bóvedas de claves (Key Vaults) o variables de entorno en el entorno productivo real.

## 2. Aplicación en Servidores "En Vivo" (Producción / Maquetas)
Aparte de corregir el repositorio, se ha verificado y ejecutado el cambio real de claves conectando vía SSH a la infraestructura. Se aseguró que **cada servidor tiene una clave root/SSH distinta e independiente**:
- **LDAP Master (10.120.22.207):** Se ha modificado exitosamente la clave de usuario root y la contraseña de administración LDAP (`cn=admin`).
- **LDAP Slave (10.120.17.242):** Se modificó la clave de root (distinta de la de Master) y se actualizó de inmediato la cadena de sincronización (Syncrepl) para que continúe replicando usando las nuevas credenciales en lugar de las comprometidas.
- **NAS (10.1.100.17):** Se forzó el cambio del usuario `root` a una clave específica e independiente, distinta a la de los servidores LDAP, para unificar la política de aislamiento total.

## 3. Restricciones de Red
Se configuró el firewall en **OpenWRT** (`OpenWRT/Config-FIREWALL.md`) bloqueando el origen indiscriminado (`*`) hacia el entorno de administración web y SSH del router. Ahora, por diseño, **solo el segmento de administración (LAN20)** podrá entablar comunicación a estos servicios vitales.

## 4. Próximos pasos recomendados
Para la integración final en el equipo del entorno:
- Inyectar las credenciales utilizando herramientas como Ansible Vault, Hashicorp Vault, o las variables secretas del pipeline (Github Actions/Gitlab CI) antes del despliegue en maquetas, evitando que se alojen en los scripts.
- Instaurar recordatorios en Zabbix cada 90 días para ejecutar la rotación estipulada de contraseñas de infraestructura.
