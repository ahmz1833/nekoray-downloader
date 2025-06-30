# Nekoray VPN Installation Script

This repository provides a Bash script to automatically download, install, and configure the **Nekoray VPN** client on Linux.

> ⚙️ **Note:** This script is an installer for [Mahdi-zarei/nekoray](https://github.com/Mahdi-zarei/nekoray/).

## 📦 What it does
- Downloads the latest (or specified) Nekoray release from GitHub
- Installs it under `~/Apps/nekoray`
- Creates a launcher script (`~/.local/bin/nekolaunch`) to run Nekoray with `pkexec`
- Downloads `nekobox.json` config
- Creates a desktop application entry in `~/.local/share/applications/nekoray.desktop`

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
rm -rf ~/Apps/nekoray ~/.local/bin/nekolaunch ~/.local/share/applications/nekoray.desktop
```

## 📄 License
MIT License.

Feel free to contribute, open issues, or suggest improvements!
