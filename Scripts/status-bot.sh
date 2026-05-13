#!/bin/bash

# Colores para terminal
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Bot de Telegram (opcional)
BOT_TOKEN="bot7754937907:AAEmXOHagArEXAh163TZ8QlxJvUJLeKP1J8"
CHAT_ID="835463082"

# Lista de servicios a comprobar
SERVICIOS=("mariadb" "smbd" "slapd" "apache2" "nginx" "bind9" "zabbix-server" ">

# Contadores
ACTIVOS=0
INACTIVOS=0
MENSAJE="------ Estado de servicios $(date) ------%0A"

# Comprobar servicios
for svc in "${SERVICIOS[@]}"; do
    if systemctl is-active --quiet "$svc"; then
        echo -e "$svc:\t${GREEN}ACTIVO${RESET}"
        ((ACTIVOS++))
        MENSAJE+="$svc: ACTIVO%0A"
    else
        echo -e "$svc:\t${RED}INACTIVO${RESET}"
        ((INACTIVOS++))
        MENSAJE+="$svc: INACTIVO%0A"
    fi
done

# Comprobar phpMyAdmin vía HTTP
if curl -s --head http://localhost/phpmyadmin | head -n 1 | grep -E "200|301" >>
    echo -e "phpMyAdmin:\t${GREEN}ACTIVO${RESET}"
    ((ACTIVOS++))
    MENSAJE+="phpMyAdmin: ACTIVO%0A"
