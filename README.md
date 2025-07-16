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
sudo bash ip6tables.sh
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
