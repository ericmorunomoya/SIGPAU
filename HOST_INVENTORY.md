# 📋 Inventario de Hosts y Funciones — Proyecto SIGPAU

Este documento detalla la topología lógica y técnica de los activos que componen el ecosistema SIGPAU.

## 🖥️ Servidores de Identidad y Base de Datos

### **sigpau01**
- **IP**: `10.120.17.242`
- **Función**: LDAP Primario (Master). Responsable de la gestión centralizada de usuarios y grupos.
- **Servicios**: OpenLDAP (389/636), NFS Server (Homes), SSH (22).
- **Acceso Remoto**: SSH (`root@10.120.17.242`).
- **Estado**: Activo / Nodo Maestro.

### **sigpau02**
- **IP**: `10.120.22.207`
- **Función**: LDAP Secundario (Mirror) y Servidor de Base de Datos.
- **Servicios**: OpenLDAP (Mirroring), MariaDB (3306), SSH (22).
- **Acceso Remoto**: SSH (`root@10.120.22.207`).
- **Estado**: Activo / Nodo de Failover.

---

## 💾 Almacenamiento Centralizado

### **NAS (Network Attached Storage)**
- **IP**: `10.1.100.17`
- **Función**: Almacenamiento RAID 5. Repositorio de backups y perfiles móviles.
- **Servicios**: OpenMediaVault, SMB/CIFS (139/445), SSH (22).
- **Acceso Remoto**: SSH (`lautaro@10.1.100.17`), Panel Web WebGUI.
- **Estado**: Activo / Backup central.

---

## 🌐 Networking y Seguridad

### **OpenWRT Router**
- **IP (LAN)**: Generalmente `.1` de cada VLAN (ej. `10.120.17.1`).
- **Función**: Core Router y Firewall. Gestión de VLANs y túneles VPN.
- **Servicios**: WireGuard VPN, DHCP, DNS, Firewall UFW/iptables.
- **Acceso Remoto**: LuCI (Web Interface), SSH.
- **VLANs**:
    - **VLAN 10/20**: Core (LDAP).
    - **VLAN 30**: Usuarios (Clientes).
    - **VLAN 50**: DMZ (Servicios Externos).
    - **VLAN 70**: Base de Datos.
    - **VLAN 80**: VPN (WireGuard).

---

## 💻 Clientes de Escritorio

### **debian-client**
- **IP**: `10.120.17.247`
- **Función**: Estación de trabajo Linux para empleados.
- **Servicios**: NSS-LDAP, PAM-Mount (Roaming Profiles).
- **Acceso Remoto**: SSH (`sysadmin@10.120.17.247`), Escritorio Remoto (VNC/X11 si aplica).
- **Estado**: Activo.

### **Windows Clients (Simulados/Integrados)**
- **IPs**: Rango VLAN 30.
- **Función**: Estaciones de trabajo integradas vía Samba AD.
- **Acceso Remoto**: **RDP (Remote Desktop Protocol)** activado por defecto para gestión administrativa.

---

## 📊 Monitorización y Dashboard
- **Dashboard Activo**: Implementado (posiblemente vía Grafana/Zabbix).
- **Funcionalidad**: Estado de "Up/Down" de hosts e indicadores de salud de servicios (Samba, LDAP).
