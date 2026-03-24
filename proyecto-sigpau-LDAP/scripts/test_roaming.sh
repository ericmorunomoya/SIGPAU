#!/bin/bash
# SIGPAU Roaming Profile Test Script
# Generado por Red Neuronal Alejabot
USERS=("eric" "lautaro" "pau")
HOME_BASE="/home/ldap-users"

for user in "${USERS[@]}"; do
    echo "--- Testing User: $user ---"
    ID_INFO=$(id "$user" 2>/dev/null)
    if [ -z "$ID_INFO" ]; then
        echo "Error: User $user not found in LDAP/AD."
        continue
    fi
    echo "ID: $ID_INFO"
    
    UHOME="$HOME_BASE/$user"
    mkdir -p "$UHOME"
    chown "$user":"admins" "$UHOME"
    
    TEST_FILE="$UHOME/test_neuronal_$(date +%Y%m%d).txt"
    echo "Escritorio Movil SIGPAU - Usuario: $user - Fecha: $(date)" > "$TEST_FILE"
    
    if [ -f "$TEST_FILE" ]; then
        echo "Success: File created at $TEST_FILE"
        ls -lh "$TEST_FILE"
        cat "$TEST_FILE"
    else
        echo "Failure: Could not create file at $TEST_FILE"
    fi
done

echo "--- Mount Verification ---"
df -h "$HOME_BASE"
