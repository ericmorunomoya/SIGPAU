# 🚀 Propuesta de Crecimiento y Evolución — Proyecto SIGPAU

Basado en el análisis de la arquitectura actual (LDAP, VLANs, Monitorización), se proponen las siguientes implementaciones para elevar el proyecto a un nivel empresarial/enterprise.

## 1. Gestión de Logs Centralizada (ELK Stack / Loki)
**Problema Actual**: Los logs están dispersos en cada host (LDAP, NAS, Router, Clientes), dificultando el diagnóstico de problemas complejos de sincronización o seguridad.
**Solución**: Implementar una pila **Elasticsearch, Logstash y Kibana (ELK)** o **Grafana Loki**.
- **Beneficio**: Búsqueda instantánea en todos los logs del sistema, alertas basadas en patrones de error y dashboards de auditoría en tiempo real.

## 2. Gestión de Secretos con HashiCorp Vault
**Problema Actual**: Se han identificado credenciales en texto plano en scripts de automatización (`Asdqwe123`, `Sigpau2026*`).
**Solución**: Desplegar **HashiCorp Vault**.
- **Beneficio**: Los scripts ya no contienen contraseñas; solicitan un token temporal a Vault que se renueva automáticamente. Elimina el riesgo de "Credential Leakage" en la documentación.

## 3. Prevención de Intrusiones (IDS/IPS) con Suricata
**Problema Actual**: El Router OpenWRT tiene un firewall robusto, pero no analiza el contenido del tráfico en busca de exploits conocidos o ataques de día cero.
**Solución**: Integrar **Suricata** en el core router.
- **Beneficio**: Detección y bloqueo automático de escaneos de red, intentos de inyección SQL (hacia la DB) y ataques de fuerza bruta antes de que lleguen a los servidores.

## 4. Automatización con Infrastructure as Code (Ansible)
**Problema Actual**: La configuración de nuevos clientes o la reparación de servidores LDAP se hace mediante scripts manuales que requieren intervención.
**Solución**: Crear un inventario y Playbooks de **Ansible**.
- **Beneficio**: Despliegue de un nuevo servidor LDAP o cliente Debian "desde cero" con un solo comando, garantizando que todos los hosts sigan exactamente la misma configuración (Compliance).

## 5. Portal de Autoservicio de Contraseñas (SSPR)
**Problema Actual**: Si un usuario olvida su contraseña LDAP, depende del administrador para resetearla.
**Solución**: Implementar **Self-Service Password Reset (SSPR)**.
- **Beneficio**: Un portal web donde el usuario puede cambiar su contraseña validando su identidad (ej. vía correo o SMS), reduciendo la carga de IT.
