#!/bin/bash

set -e

echo "[*] Stopping WireGuard interface wg0..."
sudo wg-quick down wg0

echo "[+] WireGuard has been stopped."
