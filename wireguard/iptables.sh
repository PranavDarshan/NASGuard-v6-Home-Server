# Flush old rules
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X

# Default policies
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Loopback and related traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow WireGuard
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# Allow HTTP (port 80) only from local network
sudo iptables -A INPUT -p tcp --dport 80 -s 192.168.1.0/24 -j ACCEPT

# WireGuard forwarding rules
sudo iptables -A FORWARD -i wg0 -o wlp11s0 -j ACCEPT
sudo iptables -A FORWARD -i wlp11s0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# NAT for VPN clients
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlp11s0 -j MASQUERADE

# Allow Samba ports from WireGuard clients
sudo iptables -A INPUT -i wg0 -p tcp -m multiport --dports 139,445 -j ACCEPT
sudo iptables -A INPUT -i wg0 -p udp -m multiport --dports 137,138 -j ACCEPT

