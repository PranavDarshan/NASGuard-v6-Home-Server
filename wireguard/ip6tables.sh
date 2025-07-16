# Flush existing rules
sudo ip6tables -F
sudo ip6tables -X

# Set default policies
sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT ACCEPT

# Allow loopback and established/related connections
sudo ip6tables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow essential ICMPv6 types (required for IPv6 to work properly)
sudo ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
sudo ip6tables -A FORWARD -p ipv6-icmp -j ACCEPT

# Allow WireGuard over IPv6 (UDP 51820)
sudo ip6tables -A INPUT -p udp --dport 51820 -j ACCEPT

# Allow SSH over IPv6
sudo ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP from local ULA subnet only
sudo ip6tables -A INPUT -p tcp --dport 80 -s fd00::/8 -j ACCEPT

# Allow forwarding between WireGuard and internet (for clients)
sudo ip6tables -A FORWARD -i wg0 -o wlp11s0 -j ACCEPT
sudo ip6tables -A FORWARD -i wlp11s0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow Samba over IPv6 (if used) from WireGuard clients
sudo ip6tables -A INPUT -i wg0 -p tcp -m multiport --dports 139,445 -j ACCEPT
sudo ip6tables -A INPUT -i wg0 -p udp -m multiport --dports 137,138 -j ACCEPT
