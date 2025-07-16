# Nekoray VPN Installation Script

This repository provides a Bash script to automatically download, install, and configure the **Nekoray VPN** client on Linux.

> ⚙️ **Note:** This script is an installer for [throneproj/nekoray](https://github.com/throneproj/nekoray).

## 📦 What it does

- Downloads and installs the latest (or specified) Nekoray release under `~/Apps/nekoray`
- Creates a launcher script (`~/.local/bin/nekolaunch`) to run Nekoray as root
- Creates a desktop application entry for `nekolaunch`
- Applies some configuration and adds some subscriptions for first use

> **Note that for first use, you must press Ctrl+U (Update Subscription) in each group to get the list of configs**

### ⚠️ Important Usage Notes
- You can select **"Bypass Iran"** in the Routing menu. It will directly bypass Iranian traffic and will not be proxied.
- Since the application runs as root, you must use **Tun Mode** for routing traffic. The **System Proxy** option will have no effect.
- If you need to use proxy mode instead of tunneling, you'll need to manually configure the proxy in your applications to use:
  - **Protocol:** SOCKS5
  - **Address:** 127.0.0.1:2080

## 🔧 Prerequisites
Make sure you have the following tools installed:
- `curl`
- `jq`
- `unzip`

## 🚀 Installation
You can run the installation script directly from the GitHub raw URL:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ahmz1833/nekoray-downloader/main/nekoinstall.sh)"
```

To install a specific version:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ahmz1833/nekoray-downloader/main/nekoinstall.sh) <version-tag>
```

Example:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ahmz1833/nekoray-downloader/main/nekoinstall.sh) 4.3.5-2025-05-16
```

## 📌 Launcher & Desktop Entry
After installation, you can:
- Launch from your application menu (under **Nekoray VPN**)
- Or run manually:
```bash
nekolaunch
```

## 🧹 Uninstall
Simply remove:
```bash
sudo rm -rf ~/Apps/nekoray ~/.local/bin/nekolaunch ~/.local/share/applications/nekoray.desktop
```

## 📄 License
MIT License.

Feel free to contribute, open issues, or suggest improvements!
