# NASGuard-v6-Home-Server

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
cd NASguard-v6-Home-Server
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
sudo bash ip6tables.sh
sudo netfilter-persistent save
```

### 💾 Saving Firewall Rules

To persist firewall rules across reboots:

#### 1. Install iptables-persistent

```bash
sudo apt update
sudo apt install iptables-persistent
```

#### 2. Save the Current Rules

```bash
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6
```

These rules will automatically apply on boot.

---

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

## 🖥️ Keep Debian 12 Running with Lid Closed

This section documents how to prevent your Debian 12 laptop from suspending when the lid is closed — ensuring services like Wi-Fi, SSH, and background tasks continue to operate.

### ✅ Goals

* Disable suspend on lid close
* Keep Wi-Fi and all services running
* Optional: Fully block all suspension paths (systemd targets)

### ⚙️ Steps

#### 1. Configure systemd-logind

Edit `/etc/systemd/logind.conf`:

```ini
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
```

Then apply changes:

```bash
sudo systemctl restart systemd-logind
```

#### 2. Mask system suspend targets (recommended)

Prevent all suspend actions:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

> This ensures no service or user session can suspend the system — great for 24/7 headless or docked setups.

#### 3. Disable power management daemons (optional)

Check if any are active:

```bash
systemctl list-units --type=service | grep -E 'tlp|acpid|powerd|upower|sleep'
```

Disable any unnecessary services:

```bash
sudo systemctl disable --now upower.service
```

#### 4. GNOME-specific configuration (if applicable)

As a **non-root user**, run:

```bash
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'nothing'
```

Verify with:

```bash
gsettings get org.gnome.settings-daemon.plugins.power lid-close-ac-action
gsettings get org.gnome.settings-daemon.plugins.power lid-close-battery-action
```

### 🔄 To Re-enable Suspend

Unmask the targets:

```bash
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

---

With this setup, Debian will no longer suspend on lid close, and all network and system services will continue uninterrupted.

## 🛡️ AdGuard Home (Docker) Setup

This section describes how to deploy and configure **AdGuard Home** using Docker on your Debian-based server, with support for LAN and VPN clients (via WireGuard).

---

#### 📦 Running AdGuard Home in Docker

AdGuard Home is deployed in Docker using the following command:

```bash
sudo docker run --name adguardhome -d \
  -v /opt/adguardhome/work:/opt/adguardhome/work \
  -v /opt/adguardhome/conf:/opt/adguardhome/conf \
  -p 53:53/tcp -p 53:53/udp \
  -p 3000:3000/tcp \
  adguard/adguardhome
```

* Port `53`: Standard DNS service (UDP and TCP)
* Port `3000`: AdGuard Web UI
* Data is persisted in `/opt/adguardhome/` under `work/` and `conf/`

---

#### 🔐 Firewall Configuration

Make sure your `iptables` and `ip6tables` rules allow traffic to AdGuard services:

**IPv4 rules:**

```bash
# Allow DNS from LAN
sudo iptables -A INPUT -p udp --dport 53 -s 192.168.29.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 53 -s 192.168.29.0/24 -j ACCEPT

# Allow DNS from WireGuard clients
sudo iptables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -i wg0 -p tcp --dport 53 -j ACCEPT

# Allow Web UI from LAN and WireGuard
sudo iptables -A INPUT -p tcp --dport 3000 -s 192.168.29.0/24 -j ACCEPT

```

**IPv6 rules:**

```bash
# Allow DNS from local ULA and WireGuard clients
sudo ip6tables -A INPUT -p udp --dport 53 -s fd00::/8 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport 53 -s fd00::/8 -j ACCEPT
sudo ip6tables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT
sudo ip6tables -A INPUT -i wg0 -p tcp --dport 53 -j ACCEPT

# Allow Web UI
sudo ip6tables -A INPUT -p tcp --dport 3000 -s fd00::/8 -j ACCEPT

```

---


---

#### 🔁 Persistence

To ensure Docker restarts AdGuard on boot:

```bash
sudo docker update --restart unless-stopped adguardhome
```

---

#### ⚠️ Notes

* Port 53 must be free. If `connman` or `systemd-resolved` is using it, disable them.
* You can edit AdGuard config at `/opt/adguardhome/conf/AdGuardHome.yaml`
* Use `bind_host: 0.0.0.0` to make the service available to all interfaces.

---

✅ You now have AdGuard Home running with LAN + VPN access via Docker.

## 📊 Netdata Docker Monitoring Setup

This section covers how to run and configure Netdata using Docker, with custom firewall rules and IPv6 handling.

---

### 🚀 Running Netdata via Docker

To deploy Netdata in a Docker container with cloud features disabled:

```bash
docker run -d \
  --name=netdata \
  -p 19999:19999 \
  --restart unless-stopped \
  -v netdataconfig:/etc/netdata \
  -v netdatalib:/var/lib/netdata \
  -v netdatacache:/var/cache/netdata \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  -e NETDATA_CLAIM_TOKEN=disable \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata
```

This setup disables cloud login and ensures data remains local.

---

### 🔐 Firewall Rules for Netdata Access

You can restrict access to Netdata (port `19999`) using `iptables` and `ip6tables`.

#### IPv4 Rules

* Allow access only from LAN:

```bash
sudo iptables -A INPUT -p tcp --dport 19999 -s 192.168.29.0/24 -j ACCEPT
```

* Block access from VPN clients (WireGuard):

```bash
sudo iptables -A INPUT -i wg0 -p tcp --dport 19999 -j REJECT
```

#### IPv6 Rules

* Block access from WireGuard on IPv6:

```bash
sudo ip6tables -A INPUT -i wg0 -p tcp --dport 19999 -j REJECT
```

---

## 🧪 Testing

* Use `ping 10.0.0.1` from client
* `sudo wg` on server to check VPN handshakes
* `smbclient //10.0.0.1/SecureShare -U smbuser` for Samba test
* Web UI: `http://192.168.29.4:3000` or via VPN IP
* DNS: Point clients to `192.168.29.4` or its IPv6 address (`fd00::...`)
* Configure DNS-over-HTTPS/DoT in AdGuard as needed

---

## 🔐 Security Notes

* All services are only accessible via VPN
* IPv6 traffic is isolated from the WAN
* Strong firewall rules included
* Note my home network is `192.168.29.0` therefore I have used `192.168.29.0/24` in the IP tables. Change this IP to your home network IP `192.168.x.0/24`.

---

## 🙋‍♂️ Why This Project?

This setup was created due to lack of publicly available static IPv4, while IPv6 was available. It's an attempt to use old hardware effectively and securely for modern personal cloud storage.

---

## 📮 Suggestions?

Open a GitHub issue or pull request!
