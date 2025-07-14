#!/bin/bash

set -e

KEY_NAME=${1:-peer1}

echo "[*] Generating WireGuard key pair for: $KEY_NAME"

# Create keys directory if not exists
mkdir -p keys

# Generate private key
wg genkey | tee "keys/${KEY_NAME}_private.key" | wg pubkey > "keys/${KEY_NAME}_public.key"

chmod 600 "keys/${KEY_NAME}_private.key"

echo "[+] Keys generated:"
echo "    Private: keys/${KEY_NAME}_private.key"
echo "    Public : keys/${KEY_NAME}_public.key"
