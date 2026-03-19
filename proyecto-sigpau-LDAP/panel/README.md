# 🛡️ SIGPAU Control Center

![Version](https://img.shields.io/badge/Versión-1.0--BETA-7c3aed?style=flat-square)
![Stack](https://img.shields.io/badge/Stack-Python%20%7C%20Flask%20%7C%20JS-blue?style=flat-square)
![Status](https://img.shields.io/badge/Estado-Producción-success?style=flat-square)

> **"Monitoreo en tiempo real, decisiones al instante. La infraestructura en la palma de tu mano."**

El **SIGPAU Control Center** es el corazón operativo del proyecto de Alta Disponibilidad ASIX2.
Se trata de un dashboard interactivo de última generación diseñado para ofrecer telemetría en vivo, gestión proactiva y reportes automatizados de un entorno multi-dominio (Samba AD / OpenLDAP).

No es solo un panel; es la demostración técnica de la integración End-to-End de nuestros servicios.

---

## ✨ Características WOW (Tribunal Edition)

| Funcionalidad | Descripción |
| :--- | :--- |
| 📊 **Telemetría en Vivo** | Conexiones `fetch` asíncronas cada 10s. Sin recargas de página. |
| 👥 **Gestor de Sesiones** | Descubre quién está logueado en los clientes Debian en tiempo real. |
| 💽 **Salud del RAID 5** | Monitorización de paridad y degradación del almacenamiento de los Homes NAS. |
| 📦 **Auditoría de Backups** | Consulta SQL directa a MariaDB para verificar el último volcado de LDAP. |
| 📄 **Exportación ONE-CLICK** | Generación de informes formales (HTML/PDF) con inyección de datos dinámicos listos para presentar. |
| 🎨 **UI Glassmorphism** | Diseño premium en modo oscuro con acentos violeta e indicadores reactivos. |

---

## 🏗️ Arquitectura del Panel

El panel sigue una arquitectura de microservicio integrado:

- **Backend (API Provider):** Desarrollado en **Python 3 con Flask**. Expone endpoints RESTful ligeros:
  - `/api/system`: Healthcheck de Samba AD y Kerberos.
  - `/api/sssd`: Validador multi-dominio SSSD.
  - `/api/raid` & `/api/users`: Parsers de stdout en tiempo real del Kernel Linux.
  - `/api/backups`: Conexión nativa a MariaDB.
- **Frontend (SPA):** Motorizado por Vainilla JS, CSS Grid moderno e interactividad pura sin pesadas librerías de terceros (Zero-Dependency UI).

---

## 🚀 Despliegue en 3 Pasos

Este panel está diseñado para correr como un proceso resiliente en el Servidor DC (`10.120.17.242`).

1. **Instalar dependencias clave:**
   ```bash
   apt-get install python3-flask python3-mysql.connector
   ```
2. **Arrancar en modo Demonio:**
   ```bash
   nohup python3 panel.py > panel.log 2>&1 &
   ```
3. **Acceder a la Magia:**
   Abre un navegador web y entra a `http://10.120.17.242:8080`.

---
*Diseñado y Desarrollado por **Lautaro Mir** (lautaromir07) para el tribunal ASIX2. El futuro del sysadmin es reactivo.*
