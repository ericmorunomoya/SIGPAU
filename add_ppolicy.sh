cat << 'EOF' > /tmp/load_ppolicy.ldif
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: ppolicy

dn: olcOverlay=ppolicy,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcPPolicyConfig
olcOverlay: ppolicy
olcPPolicyDefault: cn=default,ou=policies,dc=sigpau,dc=local
EOF
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/load_ppolicy.ldif
