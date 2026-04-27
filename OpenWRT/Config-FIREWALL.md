
config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'

config zone
	option output 'ACCEPT'
	option masq '1'
	option mtu_fix '1'
	option name 'WAN'
	option network 'WAN LAN100'
	option input 'ACCEPT'
	option forward 'ACCEPT'

config rule
	option name 'Allow-DHCP-Renew'
	option proto 'udp'
	option dest_port '68'
	option target 'ACCEPT'
	option family 'ipv4'
	option src 'WAN'

config rule
	option name 'Allow-Ping'
	option proto 'icmp'
	option icmp_type 'echo-request'
	option family 'ipv4'
	option target 'ACCEPT'
	option src 'WAN'

config rule
	option name 'Allow-IGMP'
	option proto 'igmp'
	option family 'ipv4'
	option target 'ACCEPT'
	option src 'WAN'

config rule
	option name 'Allow-DHCPv6'
	option proto 'udp'
	option src_ip 'fc00::/6'
	option dest_ip 'fc00::/6'
	option dest_port '546'
	option family 'ipv6'
	option target 'ACCEPT'
	option src 'WAN'

config rule
	option name 'Allow-MLD'
	option proto 'icmp'
	option src_ip 'fe80::/10'
	list icmp_type '130/0'
	list icmp_type '131/0'
	list icmp_type '132/0'
	list icmp_type '143/0'
	option family 'ipv6'
	option target 'ACCEPT'
	option src 'WAN'

config rule
	option name 'Allow-ICMPv6-Input'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	list icmp_type 'router-solicitation'
	list icmp_type 'neighbour-solicitation'
	list icmp_type 'router-advertisement'
	list icmp_type 'neighbour-advertisement'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'
	option src 'WAN'

config rule
	option name 'Allow-ICMPv6-Forward'
	option dest '*'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'
	option src 'WAN'

config include
	option path '/etc/firewall.user'

config zone
	option input 'ACCEPT'
	option forward 'ACCEPT'
	option output 'ACCEPT'
	option name 'LAN20'
	option network 'LAN20'

config zone
	option input 'ACCEPT'
	option forward 'ACCEPT'
	option output 'ACCEPT'
	option name 'LAN30'
	option network 'LAN30'

config zone
	option input 'ACCEPT'
	option forward 'ACCEPT'
	option output 'ACCEPT'
	option name 'LAN40'
	option network 'LAN40'

config zone
	option input 'ACCEPT'
	option forward 'ACCEPT'
	option output 'ACCEPT'
	option name 'LAN50'
	option network 'LAN50'

config forwarding
	option dest 'WAN'
	option src 'LAN20'

config forwarding
	option dest 'WAN'
	option src 'LAN30'

config forwarding
	option dest 'WAN'
	option src 'LAN40'

config forwarding
	option dest 'WAN'
	option src 'LAN50'

config rule
	option target 'ACCEPT'
	option proto 'tcp'
	option dest_port '80'
	option name 'ADMIN'
	option src 'LAN20'

config rule
	option target 'ACCEPT'
	option dest_port '22'
	option name 'SSH'
	option src 'LAN20'
	option proto 'tcp udp'

config rule
	option target 'ACCEPT'
	option proto 'tcp'
	option dest_port '22'
	option src '*'
	option dest_ip '10.120.22.207'
	option name 'sshlan20'
	option dest 'LAN20'

config rule
	option target 'ACCEPT'
	option proto 'tcp'
	option dest_port '22'
	option name 'sshlan10'
	option dest '*'
	option dest_ip '10.120.17.242'

config rule
	option target 'ACCEPT'
	option dest_port '389'
	option name 'Ldap'
	option src '*'
	option dest_ip '10.120.17.242'
	option proto 'tcp'
	option dest '*'

config rule
	option target 'ACCEPT'
	option dest_port '389'
	option name 'ldap2'
	option src '*'
	option dest_ip '10.120.22.207'
	option proto 'tcp'
	option dest 'LAN20'

config rule
	option name 'Allow-PC-to-LAN'
	option src 'WAN'
	option dest '*'
	option target 'ACCEPT'

config rule
	option name 'Allow-NFS'
	option src 'WAN'
	option dest_port '2049 111'
	option proto 'tcp udp'
	option target 'ACCEPT'

config rule
	option name 'Trust-Client'
	option src 'WAN'
	option src_ip '10.1.105.121'
	option target 'ACCEPT'

config rule
	option name 'Allow-Samba'
	option src '*'
	option proto 'tcp udp'
	option dest_port '137 138 139 445'
	option target 'ACCEPT'

config zone
	option name 'vpn'
	option input 'ACCEPT'
	option forward 'ACCEPT'
	option output 'ACCEPT'
	option network 'vpn'
	option masq '1'
	option mtu_fix '1'

config rule
	option target 'ACCEPT'
	option name 'Allow-WG-Inbound'
	option proto 'udp'
	option src 'WAN'
	option dest_port '51820'

config zone 'vpn'
	option name 'vpn'
	option input 'ACCEPT'
	option forward 'ACCEPT'
	option output 'ACCEPT'
	option masq '1'
	list network 'vpn'
	option mtu_fix '1'

config rule
	option name 'Allow-WG-Local-Traffic'
	option src 'lan'
	option dest_port '51820'
	option proto 'udp'
	option target 'ACCEPT'

config forwarding
	option dest 'WAN'
	option src 'vpn'

config forwarding
	option dest 'vpn'
	option src 'WAN'

