#!/bin/bash

# Flush all existing rules
iptables -F
iptables -t nat -F
iptables -t mangle -F
ip6tables -F
ip6tables -t nat -F
ip6tables -t mangle -F

# Set default policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

# === IPv4 NAT Rules ===
# Masquerade traffic from wg0 to outbound interface (wlp11s0)
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlp11s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlp11s0 -j MASQUERADE

# === IPv4 FORWARD Rules ===
iptables -A FORWARD -i wg0 -o wlp11s0 -j ACCEPT
iptables -A FORWARD -i wlp11s0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wg0 -o wlp11s0 -j ACCEPT
iptables -A FORWARD -i wlp11s0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# === IPv6 Rules ===
# These are default ACCEPT for all chains
# No NAT is applied unless using special IPv6 NPT66
ip6tables -t mangle -P PREROUTING ACCEPT
ip6tables -t mangle -P INPUT ACCEPT
ip6tables -t mangle -P FORWARD ACCEPT
ip6tables -t mangle -P OUTPUT ACCEPT
ip6tables -t mangle -P POSTROUTING ACCEPT

# Ensure persistence
netfilter-persistent save
