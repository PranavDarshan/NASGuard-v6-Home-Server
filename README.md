# NASGuard-v6 

> A lightweight, IPv6-only NAS with secure WireGuard VPN access. Built on Debian 12 (32-bit) for older hardware with public static IPv6. Samba is used for file sharing over the private VPN.
<img src=https://github.com/PranavDarshan/NASguard-v6/blob/main/assets/output.png/>

---

## 🔧 Features

* Secure IPv6 NAS with no public IPv4
* WireGuard VPN to bridge IPv4-only clients
* Samba file sharing
* Full firewall and routing config
* Designed for low-spec machines (e.g. old laptops)

---

## 📦 Prerequisites

* [Debian 12](https://www.debian.org/download) (i386 / 32-bit) Server installed
* Public Static IPv6 address
* Internal-only IPv4

---

## 🛠️ Setup Guide

### 1. Clone this Repo

```bash
git https://github.com/PranavDarshan/NASguard-v6
cd NASguard-v6
```

### 2. Setup WireGuard VPN

#### a. Generate keys

```bash
chmod +x generate-key.sh
./generate-key.sh client1
```

Keys will be saved in `keys/` folder.

#### b. Configure Routing

```bash
sudo bash iptables.sh
sudo netfilter-persistent save
```

Ensure `wg0` forwards traffic properly (already configured in `iptables.sh`).

#### After IP tables are set up, you should get something like this.

<img src=https://github.com/PranavDarshan/NASguard-v6/blob/main/assets/iptables.png/>


#### c. Start WireGuard on Boot

```bash
sudo cp start-wireguard.sh /etc/init.d/
sudo chmod +x /etc/init.d/start-wireguard.sh
sudo update-rc.d start-wireguard.sh defaults
```

To stop manually:

```bash
sudo bash stop-wireguard.sh
```

---

#### Once wireguard is started, you can see the output as:

<img src=https://github.com/PranavDarshan/NASguard-v6/blob/main/assets/wgshow.png/>

<img src=https://github.com/PranavDarshan/NASguard-v6/blob/main/assets/wgsystemctl.png/>

### 3. Setup Samba

#### a. Configure share

```bash
cd samba
chmod +x samba-setup.sh
./samba-setup.sh
```

This creates:

* User `smbuser`
* Share at `/srv/samba/secure`

#### b. Access via VPN

Once VPN is up from a client, access share using:

```
\\10.0.0.1\SecureShare
```

Use credentials created via `samba-setup.sh`

---

## 🧪 Testing

* Use `ping 10.0.0.1` from client
* `sudo wg` on server to check VPN handshakes
* `smbclient //10.0.0.1/SecureShare -U smbuser` for Samba test

---

## 🔐 Security Notes

* All services are only accessible via VPN
* IPv6 traffic is isolated from the WAN
* Strong firewall rules included

---

## 🙋‍♂️ Why This Project?

This setup was created due to lack of publicly available static IPv4, while IPv6 was available. It's an attempt to use old hardware effectively and securely for modern personal cloud storage.

---

## 📮 Suggestions?

Open a GitHub issue or pull request!
