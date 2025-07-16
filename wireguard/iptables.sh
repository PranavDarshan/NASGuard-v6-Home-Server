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

# Allow SSH only from LAN
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.29.0/24 -j ACCEPT

# Allow SSH only from VPN (WireGuard subnet)
sudo iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -j ACCEPT


# Allow WireGuard (UDP 51820)
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# Allow HTTP from LAN only
sudo iptables -A INPUT -p tcp --dport 80 -s 192.168.29.0/24 -j ACCEPT

# Allow DNS (UDP + TCP 53) from LAN
sudo iptables -A INPUT -p udp --dport 53 -s 192.168.29.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 53 -s 192.168.29.0/24 -j ACCEPT

# Allow DNS from WireGuard clients
sudo iptables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i wg0 -p tcp --dport 53 -j ACCEPT

# Allow AdGuard Web UI (port 3000) from LAN
sudo iptables -A INPUT -p tcp --dport 3000 -s 192.168.29.0/24 -j ACCEPT

# Allow Samba from WireGuard clients
sudo iptables -A INPUT -i wg0 -p tcp -m multiport --dports 139,445 -j ACCEPT
sudo iptables -A INPUT -i wg0 -p udp -m multiport --dports 137,138 -j ACCEPT

# Allow forwarding for WireGuard VPN clients
sudo iptables -A FORWARD -i wg0 -o wlp11s0 -j ACCEPT
sudo iptables -A FORWARD -i wlp11s0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# NAT for VPN clients
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlp11s0 -j MASQUERADE
