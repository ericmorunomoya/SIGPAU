
config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'

config zone
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'
	option name 'WAN'
	list network 'WAN'
	list network 'LAN100'

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

config rule
	option target 'ACCEPT'
	option dest_port '22'
	option name 'SSH'
	option src '*'

config rule
	option proto 'tcp'
	option dest_port '22'
	option dest_ip '10.120.22.207'
	option name 'sshlan20'
	option dest 'LAN20'

	option proto 'tcp'
	option dest_port '22'
	option name 'sshlan10'
	option dest '*'
	option dest_ip '10.120.17.242'
	option target 'ACCEPT'
	option dest_port '389'
	option name 'Ldap'
	option src '*'
	option proto 'tcp'
	option dest '*'
config rule
	option enabled '1'
	option target 'ACCEPT'
	option name 'ldap2'

	option src '*'
	option dest 'LAN20'
	option dest_ip '10.120.22.207'
	option proto 'tcp'
	option dest_port '389'

	option dest_ip '10.120.17.242'

config rule
config rule
	option target 'ACCEPT'
	option src '*'
	option target 'ACCEPT'
	option proto 'tcp udp'

