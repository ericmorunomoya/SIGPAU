# SIGPAU - Sistema Integral de Gestión y Provisionamiento de Usuarios

## 📋 Descripción del Proyecto
SIGPAU es una infraestructura corporativa diseñada para la gestión centralizada de identidades y recursos mediante protocolos de estándar abierto. El sistema implementa alta disponibilidad (MMR) en servicios de directorio, almacenamiento redundante en red (NAS) y una segmentación de red estricta mediante VLANs.

Este repositorio contiene las soluciones de seguridad y mejoras de infraestructura aplicadas en la fase de consolidación técnica del proyecto.

## 🚀 Implementaciones Realizadas

### 1. Fortalecimiento de la Seguridad TLS
Se ha identificado y resuelto una vulnerabilidad en los certificados de servicios de directorio. Se han implementado nuevos certificados basados en **SHA-256** con llaves de **RSA 4096 bits**.
- **Solución**: `security_fixes/update_sigpau_tls.sh`
- **Cambios**: Actualización de la Autoridad de Certificación (CA) interna y restricción de protocolos a **TLS 1.2+** para mitigar vulnerabilidades heredadas.

### 2. Gestión de Logs con Grafana Loki
Para mejorar la observabilidad del sistema, se ha desplegado una pila de monitorización de logs centralizada.
- **Configuración**: `growth_solutions/docker-compose.yml`
- **Alcance**: Recolección de logs de servidores LDAP, servicios Samba y almacenamiento NAS mediante agentes Promtail, visualizados en un dashboard unificado de Grafana.

### 3. Automatización con Infrastructure as Code (Ansible)
Se ha integrado un marco de automatización para la gestión de flotas y configuración de servidores.
- **Inventario**: `ansible/hosts.ini`
- **Playbook**: `ansible/hardening.yml`
- **Función**: Permite la propagación masiva de certificados de seguridad, actualizaciones de paquetes y auditoría de red en todos los nodos del ecosistema (`sigpau01`, `sigpau02`, `NAS`, `debian-client`).

## 🗺️ Inventario de Infraestructura
Para detalles técnicos sobre IPs, roles y métodos de acceso, consulte el documento maestro:
- [HOST_INVENTORY.md](HOST_INVENTORY.md)

## 🛠️ Guía de Uso de Soluciones
1.  **Actualización TLS**: Ejecutar `./security_fixes/update_sigpau_tls.sh` en el servidor maestro.
2.  **Despliegue de Logs**: Ejecutar `docker-compose up -d` en el directorio `growth_solutions/`. El panel de Grafana estará accesible en el puerto **4500**.
3.  **Dashboards Chulos**: Puedes importar el archivo `growth_solutions/dashboard_loki.json` en Grafana para tener las gráficas de actividad listas al instante.
4.  **Auditoría con Ansible**: Ejecutar `ansible-playbook -i hosts.ini hardening.yml` desde la estación de gestión.

---
**Autores**: Pau Gamez, Eric Moruno y Lautaro Mir.  
**Fecha**: Marzo 2026.
