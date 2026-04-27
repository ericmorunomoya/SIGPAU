# Políticas y Mejoras de Seguridad - SIGPAU

En respuesta a las observaciones de seguridad, se han implementado y documentado las siguientes mejoras para garantizar el correcto aislamiento y protección del entorno:

## 1. Política de contraseñas diferenciadas por servicio
Se ha abandonado el uso de la contraseña compartida (`Asdqwe123`) para todos los servicios de la demo. La nueva política establece credenciales únicas y robustas por servicio para evitar movimientos laterales en caso de compromiso:
- **LDAP:** `Ldap@Pass123!` (Actualizado en los scripts de despliegue y réplica `create_users.sh`, `02-setup-n2.sh` y `02-ldap-consumer.ldif`).
- **SSH:** `Ssh@Pass123!`
- **Zabbix:** `Zabbix@Pass123!`
- **Router (OpenWRT):** `Router@Pass123!`

## 2. Autenticación Multifactor (MFA) para accesos críticos
Para añadir una capa adicional de protección a los servicios críticos, se requiere la implementación de Autenticación Multifactor (MFA):
- **Servidores Linux / SSH:** Ya disponemos del script `install_2fa.sh` para integrar *Google Authenticator* mediante libpam.
- **Zabbix:** Se debe configurar la autenticación en dos pasos (TOTP) nativa desde el frontend de administración de Zabbix (Users > Authentication > MFA).
- **Router (OpenWRT):** El acceso SSH al router debe configurarse para admitir autenticación de clave pública obligatoria junto con MFA, o utilizar un servidor de salto bastionizado.

## 3. Rotación periódica de credenciales
Se establece una política de rotación de contraseñas:
- Las contraseñas de servicio e infraestructura (LDAP admin, bases de datos) se rotarán cada **90 días**.
- Se forzará la expiración de las contraseñas de los usuarios mediante las políticas de *ShadowAccount* en LDAP (por ejemplo, `shadowMax: 90`), obligando a cambiar sus credenciales en el siguiente inicio de sesión tras caducar.

## 4. Restricción de acceso al router por IP de origen
El acceso a la interfaz de administración del router (HTTP puerto 80) y por SSH (puerto 22) ya no está permitido globalmente.
- Se ha modificado el archivo de configuración del firewall (`OpenWRT/Config-FIREWALL.md`) para restringir el acceso entrante a estos servicios únicamente desde la VLAN de administración (`LAN20`).
- Cualquier intento de acceso desde otras redes (`LAN30`, `LAN40`, `LAN50`, `WAN`) será rechazado de acuerdo a la política predeterminada del firewall.
