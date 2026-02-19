# 05 - RAID 5 en el NAS

## Objetivo
Configurar RAID 5 en el NAS (`10.1.100.17`) con 4 discos para almacenamiento redundante de los directorios home.

## Discos
| Disco | Tamaño | Función |
|-------|--------|---------|
| **sda** | 223 GB | Sistema operativo (NO se toca) |
| **sdb** | 931 GB | RAID 5 |
| **sdc** | 931 GB | RAID 5 |
| **sdd** | 931 GB | RAID 5 |
| **sde** | 931 GB | RAID 5 |

**Capacidad RAID 5:** 2.73 TB (3 discos útiles + 1 paridad)

## Procedimiento

### 1. Instalar mdadm
```bash
apt install -y mdadm
```

### 2. Limpiar discos
```bash
wipefs -a /dev/sdb
wipefs -a /dev/sdc
wipefs -a /dev/sdd
wipefs -a /dev/sde
```

### 3. Crear RAID 5
```bash
mdadm --create /dev/md0 --level=5 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde
```

### 4. Formatear
```bash
mkfs.ext4 -F /dev/md0
```

### 5. Montar temporalmente y copiar datos
```bash
mkdir -p /mnt/raid5
mount /dev/md0 /mnt/raid5
cp -a /home/* /mnt/raid5/
```

### 6. Hacer persistente
```bash
# Guardar configuración mdadm
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u

# Desmontar y remontar como /home
umount /mnt/raid5
umount /home
mount /dev/md0 /home

# Actualizar fstab (quitar sda8, añadir RAID)
UUID_RAID=$(blkid -s UUID -o value /dev/md0)
sed -i '/sda8/d' /etc/fstab
echo "UUID=$UUID_RAID /home ext4 defaults 0 2" >> /etc/fstab
```

### 7. Verificar
```bash
# Estado del RAID
cat /proc/mdstat
mdadm --detail /dev/md0

# Montaje
df -h /home
ls -la /home/
```

## Resultado
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        2.7T   81M  2.6T   1% /home
```

## Notas
- La sincronización inicial del RAID tarda ~4 horas
- El RAID es funcional durante la sincronización
- Si falla 1 disco, el RAID sigue operativo (modo degradado)
- Para reemplazar un disco fallido: `mdadm --manage /dev/md0 --add /dev/sdX`
