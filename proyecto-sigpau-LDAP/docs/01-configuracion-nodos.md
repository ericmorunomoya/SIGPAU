# Configuración de Nodos LDAP (MirrorMode)

## Nodo 01 (Maestro/Proveedor)
1. Asignar `olcServerID: 1`.
2. Cargar módulo `syncprov`.
3. Configurar Overlay `syncprov` en la base de datos `{1}mdb`.

## Nodo 02 (Esclavo/Consumidor)
1. Asignar `olcServerID: 2`.
2. Configurar `olcSyncrepl` apuntando a la IP del Nodo 01.
3. Activar `olcMirrorMode: TRUE`.

### Verificación
```bash
ldapsearch -x -LLL -s base -b "dc=sigpau,dc=local" contextCSN
```
