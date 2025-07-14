#!/bin/bash

set -e

echo "[*] Enabling IP forwarding (IPv4 + IPv6)..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

echo "[*] Starting WireGuard interface wg0..."
sudo wg-quick up wg0

echo "[+] WireGuard is up. Routing and NAT already handled by persistent iptables."
sudo systemctl enable wg-quick@wg0
