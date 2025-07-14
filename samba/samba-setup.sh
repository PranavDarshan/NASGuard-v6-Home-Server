#!/bin/bash

set -e

USERNAME=smbuser
SHARE_PATH=/srv/samba/secure

echo "[*] Installing Samba..."
sudo apt update && sudo apt install -y samba

echo "[*] Creating user: $USERNAME"
sudo useradd -M -s /usr/sbin/nologin $USERNAME || echo "User $USERNAME may already exist"
sudo smbpasswd -a $USERNAME

echo "[*] Creating shared directory: $SHARE_PATH"
sudo mkdir -p "$SHARE_PATH"
sudo chown $USERNAME:$USERNAME "$SHARE_PATH"
sudo chmod 770 "$SHARE_PATH"

echo "[*] Copying smb.conf to /etc/samba/"
sudo cp smb.conf /etc/samba/smb.conf

echo "[*] Restarting Samba services..."
sudo systemctl restart smbd nmbd

echo "[+] Samba setup complete."
