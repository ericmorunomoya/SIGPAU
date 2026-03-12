# Documentación del Sistema de Monitorización y Failover en Docker

Este documento detalla la arquitectura y funcionamiento del sistema híbrido creado para vigilar el **Router Principal** y proporcionar un mecanismo de failover interactivo para levantar el **Router de Backup** alojado en VirtualBox.

## 1. Arquitectura del Sistema

El sistema utiliza lo mejor de dos mundos: **Docker** para proporcionar interfaces web profesionales (Páginas Web y Gráficas), y **Windows (Host)** para poder controlar las máquinas virtuales físicas locales (VirtualBox).

Consta de **3 componentes principales**:

### A) Uptime Kuma (Contenedor Docker - Puerto 3001)
- **Función**: Actúa como el panel de control visual para ver el historial a largo plazo, métricas de red y gráficas de caídas.
- **Acceso**: `http://localhost:3001`
- **Operación**: Realiza "pings" automáticos cada 20 segundos al Router Principal y guarda un registro del tiempo de actividad.

### B) Interfaz de Failover UI (Contenedor Docker - Puerto 3002)
- **Función**: Es una aplicación web moderna (HTML/JS/CSS) diseñada específicamente para reaccionar a la caída del servidor. Reemplaza la funcionalidad de alerta del antiguo script en AHK.
- **Acceso**: `http://localhost:3002`
- **Operación**: Esta página web pregunta el estado de las máquinas físicas cada 15 segundos al *Puente* en Windows. Si detecta que el router principal está apagado, lanza una alerta visual e interactiva (Sí/No) preguntando si el usuario desea levantar el router de backup.
- **Archivos**: El código (un `index.html` modificado y compilado usando NGINX Alpine en `Dockerfile`) está dentro de la carpeta `failover-ui/`.

### C) Host-Bridge (Script Local de PowerShell - Puerto 9001)
- **Función**: Dado que Docker está aislado y no puede manipular (por temas de seguridad) los procesos de Windows ni las máquinas VirtualBox por sí mismo, este script hace de "Puente de mando" entre la web de interfaz (que está en Docker) y el VirtualBox físico (que está en Windows).
- **Operación**:
  - Abre un mini-servidor web oculto en el puerto `9001` en Windows (`http://127.0.0.1:9001/`).
  - Alguien en la red local (la Interfaz de Failover UI de Docker) puede pedirle datos usando rutas simples:
    - `GET /status`: Responde en formato JSON indicando si el Servidor Principal y/o el Backup están corriendo, usando el comando `VBoxManage list runningvms`.
    - `POST /start-backup`: Recibe la orden y ejecuta silenciosamente el comando `VBoxManage startvm "Router- Servidor-Backup"`.
- **Archivos**: `Host-Bridge.ps1` (El script principal) y `Iniciar-Puente.bat` (Lanzador cómodo para saltarse el bloqueo de PowerShell en Windows).

---

## 2. Flujo de Trabajo (¿Qué pasa cuando se cae el Router?)

1. Supongamos que se apaga el Router Principal.
2. Tienes abierta tu página `http://localhost:3002`. Cada 15 segundos su script de `index.html` envía una petición a la máquina Windows (`http://127.0.0.1:9001/status`).
3. El script de tu PC le responde con la información: *"Oye, VirtualBox me dice que el principal NO está, y tampoco el backup."*.
4. Al recibir eso, la interfaz de la web `3002` muestra la ventana pop-up (alert/confirm) de Windows nativo en tu navegador: *"El Servidor Principal está APAGADO. ¿Quieres encender el Router de Backup?"*.
5. Si pulsas "Sí", la página web envía otra petición (`POST /start-backup`) a Windows.
6. El script de PowerShell en Windows la atrapa y ejecuta físicamente `VBoxManage startvm` para subir el router de emergencia.

---

## 3. Instrucciones de Uso y Lanzamiento

Siempre que vayas a trabajar en tu entorno y quieras tener montada la vigilancia, sigue estos 2 sencillos pasos:

### 3.1. Enciende el Puente (Windows)
1. Ve a esta carpeta y localiza el archivo `Iniciar-Puente.bat`.
2. Haz **doble clic** en él.
3. Se abrirá una pequeña ventana negra que indicará que está escuchando peticiones en el puerto 9001. *(Minimízala y déjala encendida)*.

### 3.2. Enciende los Paneles (Docker)
1. Abre una terminal normal (o PowerShell) en esta misma carpeta y ejecuta:
   ```bash
   docker-compose up -d
   ```
2. Abre en tu navegador de preferencia:
   - Para las **Gráficas e Historial**: `http://localhost:3001`
   - Para el **Asistente de Failover (El Botón y las Alertas)**: `http://localhost:3002`

Para dejar de monitorizar o salir del sistema, simplemente cierra el archivo `.bat` (Puente de Windows) y detén los contenedores de Docker (`docker-compose down`).
