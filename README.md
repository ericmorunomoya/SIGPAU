# SIGPAU - Sistema Integral de Gestión y Provisión Automática de Usuarios

## Descripción General

**SIGPAU** es un proyecto integral de gestión y provisión automática de usuarios, diseñado para ofrecer soluciones robustas de ciberseguridad y gestión de Tecnologías de la Información (TI) a Pequeñas y Medianas Empresas (PYMES) y entornos educativos. Basado en herramientas de código abierto (open-source), SIGPAU aborda desafíos clave en la administración de redes y servicios de TI, proporcionando automatización, seguridad avanzada y eficiencia operativa.

## Características Principales

El proyecto SIGPAU se distingue por las siguientes características fundamentales:

- **Automatización Integral:** Gestión automatizada de usuarios, copias de seguridad programadas y monitorización continua.

- **Ciberseguridad Avanzada:** Implementación de autenticación de doble factor (2FA), auditorías de acceso y cumplimiento de normativas de seguridad.

- **Reducción de Costes:** Optimización de recursos y uso de soluciones open-source para minimizar los gastos operativos.

- **Escalabilidad:** Arquitectura diseñada para soportar entornos híbridos (cloud y on-premise) y adaptarse al crecimiento de la organización.

- **Alertas en Tiempo Real:** Notificaciones instantáneas y dashboards interactivos para una supervisión proactiva.

## Servicios Ofrecidos

SIGPAU proporciona un conjunto de servicios clave para una infraestructura de TI completa y segura:

### Gestión de Redes y Arquitectura

- Diseño e implementación de arquitecturas de red robustas con VLANs y gateways OpenWRT.

- Configuración de servidores DNS locales para una resolución de nombres eficiente.

### Seguridad y Autenticación

- Autenticación centralizada mediante LDAP y Kerberos.

- Autenticación de doble factor (2FA) con Google Authenticator.

- Políticas de contraseñas robustas y auditorías de trazabilidad.

### Gestión de Datos y Aplicaciones

- Configuración de bases de datos SQL con datos de prueba.

- Desarrollo de páginas web internas con acceso restringido.

- Compartición segura de carpetas (Samba) por departamento.

### Automatización y Recuperación

- Copias de seguridad automatizadas de datos y servicios críticos.

- Generación de imágenes del sistema para una recuperación rápida.

- Scripts de restauración para verificación y reinicio automático de servicios.

### Monitorización y Alertas

- Monitorización proactiva de la red con Zabbix.

- Pantallas de monitorización en tiempo real (ping, tráfico VLAN, usuarios conectados).

- Notificaciones instantáneas a través de bots de Telegram.

## Arquitectura y Componentes Técnicos

La solución SIGPAU se basa en una infraestructura técnica sólida que integra diversas herramientas y protocolos open-source:

- **Virtualización:** OpenWRT para gateways y segmentación de red (VLANs).

- **Autenticación:** LDAP y Kerberos para la gestión unificada de usuarios.

- **Seguridad:** Google Authenticator para 2FA, auditorías de accesos SSH/SMB.

- **Bases de Datos:** SQL para la gestión de datos.

- **Servicios de Archivos:** Samba para compartición de carpetas.

- **Monitorización:** Zabbix y LibreNMS/The Dude para la supervisión de la infraestructura.

- **Notificaciones:** Integración con Telegram para alertas en tiempo real.

## Estructura del Repositorio

Este repositorio contiene los componentes esenciales del proyecto SIGPAU. A continuación, se detalla la estructura principal:

```
.
├── scripts/            # Scripts de automatización, restauración y monitorización.
├── web/                # Archivos de configuración de nuestra web.
└── README.md           # Este archivo.
```

### `scripts/`

Aquí se encuentran los diversos scripts que automatizan tareas, facilitan la restauración de servicios y contribuyen a la monitorización del sistema. Incluye, entre otros, scripts para:

- Restauración de servicios.

- Verificación del estado del sistema.

- Generación de informes de auditoría.

- Gestión de usuarios y permisos.

### `web/`

Contiene los archivos de configuración, código fuente y activos necesarios para el portal web interno de SIGPAU. Este portal sirve como interfaz central para los usuarios y administradores, permitiendo:

- Visualización de informes de auditoría.

- Acceso restringido a servicios corporativos.

- Gestión de perfiles y documentación interna.

## Contribución

¡Las contribuciones son bienvenidas! Si desea mejorar este proyecto, por favor, siga estos pasos:

1. Realice un 'fork' del repositorio.

1. Cree una nueva rama (`git checkout -b feature/nueva-funcionalidad`).

1. Realice sus cambios y haga 'commit' (`git commit -m 'Añadir nueva funcionalidad'`).

1. Suba sus cambios a su 'fork' (`git push origin feature/nueva-funcionalidad`).

1. Abra un 'Pull Request' describiendo sus cambios.

## Contacto

Para cualquier consulta o sugerencia, puede contactar con el equipo de desarrollo:

- [pau.gamez.pacheco@ieselcalamot.com](mailto:pau.gamez.pacheco@ieselcalamot.com)

- [eric.moruno.moya@ieselcalamot.com](mailto:eric.moruno.moya@ieselcalamot.com)

- [lautaro.mir@ieselcalamot.com](mailto:lautaro.mir@ieselcalamot.com)



