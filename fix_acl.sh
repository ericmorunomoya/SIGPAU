sshpass -p 'Asdqwe123' ssh -o StrictHostKeyChecking=no root@10.120.17.242 "cat << 'EOF' > /tmp/acl.ldif
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * none
olcAccess: {1}to attrs=shadowLastChange by self write by * read
olcAccess: {2}to * by * read
EOF
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/acl.ldif
"
