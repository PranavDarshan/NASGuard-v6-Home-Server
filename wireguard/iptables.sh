# Flush existing rules
sudo ip6tables -F
sudo ip6tables -X

# Default policies
sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT ACCEPT

# Loopback and related connections
sudo ip6tables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Essential ICMPv6
sudo ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
sudo ip6tables -A FORWARD -p ipv6-icmp -j ACCEPT

# WireGuard
sudo ip6tables -A INPUT -p udp --dport 51820 -j ACCEPT

# SSH
sudo ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

# HTTP from local IPv6 (ULA) subnet
sudo ip6tables -A INPUT -p tcp --dport 80 -s fd00::/8 -j ACCEPT

# DNS from LAN over IPv6
sudo ip6tables -A INPUT -p udp --dport 53 -s fd00::/8 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport 53 -s fd00::/8 -j ACCEPT

# DNS from WireGuard clients
sudo ip6tables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT
sudo ip6tables -A INPUT -i wg0 -p tcp --dport 53 -j ACCEPT

# AdGuard Web UI from local ULA
sudo ip6tables -A INPUT -p tcp --dport 3000 -s fd00::/8 -j ACCEPT

# Samba from WireGuard clients
sudo ip6tables -A INPUT -i wg0 -p tcp -m multiport --dports 139,445 -j ACCEPT
sudo ip6tables -A INPUT -i wg0 -p udp -m multiport --dports 137,138 -j ACCEPT

# WireGuard client internet access
sudo ip6tables -A FORWARD -i wg0 -o wlp11s0 -j ACCEPT
sudo ip6tables -A FORWARD -i wlp11s0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
