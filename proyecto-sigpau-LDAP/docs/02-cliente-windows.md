# Guía de Conexión Cliente Windows 10/11

Para unir un cliente Windows moderno a un dominio Samba NT4-Style en subredes diferentes, sigue estos pasos:

## 1. Ajustes de Registro (Admin PowerShell)
```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "DomainCompatibilityMode" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "DNSNameResolutionRequired" -Value 0 -PropertyType DWORD -Force
```

## 2. Configuración de Red (WINS)
1. `ncpa.cpl` > Propiedades IPv4 > Avanzadas > WINS.
2. Añadir IP del Nodo 01: `10.120.17.242`.
3. Marcar **"Habilitar NetBIOS sobre TCP/IP"**.

## 3. Archivo LMHOSTS
Editar `C:\Windows\System32\drivers\etc\lmhosts`:
```text
10.120.17.242   NODO01   #PRE #DOM:SIGPAU
```
Ejecutar `nbtstat -R` para aplicar.
