#!/usr/bin/env bash

set -e

# Configurable variables
REPO="Mahdi-zarei/nekoray"
ASSET_SUFFIX="linux64.zip"
INSTALL_DIR="$HOME/Apps"
APP_DIR="$INSTALL_DIR/nekoray"
LAUNCHER="$HOME/.local/bin/nekolaunch"
DESKTOP_FILE="$HOME/.local/share/applications/nekoray.desktop"
ICON_PATH="$APP_DIR/nekobox.png"
APP_NAME="Nekoray VPN"
COMMENT="NekoRay VPN (V2ray Application)"

# Ensure required tools
for cmd in jq curl unzip; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not installed." >&2
        exit 1
    fi
done

# Create temp dir
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download asset
download_nekoray() {
    local version="$1"
    local release_json download_url

    if [ -z "$version" ]; then
        echo "Fetching latest release info..."
        release_json=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest")
    else
        echo "Fetching release info for version: $version"
        release_json=$(curl -s "https://api.github.com/repos/${REPO}/releases/tags/${version}")
    fi

    download_url=$(echo "$release_json" | jq -r ".assets[] | select(.name | test(\"${ASSET_SUFFIX}$\")) | .browser_download_url")

    if [ -z "$download_url" ] || [ "$download_url" == "null" ]; then
        echo "Error: Couldn't find asset ending with '$ASSET_SUFFIX' for this release."
        exit 1
    fi

    echo "Downloading: $download_url"
    curl -LO "$download_url"
}

# Parse argument (optional version)
if [ $# -ge 1 ]; then
    VERSION="$1"
else
    VERSION=""
fi

download_nekoray "$VERSION"

# Find downloaded zip file
ZIP_FILE=*.zip

# Ensure ~/Apps exists
mkdir -p "$INSTALL_DIR"

# Remove existing installation if any
rm -rf "$APP_DIR"

# Extract into ~/Apps
echo "Extracting to $INSTALL_DIR..."
unzip -q "$ZIP_FILE" -d "$INSTALL_DIR"

# After unzip, folder should be $INSTALL_DIR/nekoray
if [ ! -d "$APP_DIR" ]; then
    echo "Error: Expected folder $APP_DIR not found after extraction."
    exit 1
fi

# Create launcher script
echo "Creating launcher script at $LAUNCHER..."
mkdir -p "$(dirname "$LAUNCHER")"
cat > "$LAUNCHER" <<EOF
#!/bin/sh
pkexec env DISPLAY=\$DISPLAY XAUTHORITY=\$XAUTHORITY "$APP_DIR/nekoray"
EOF
chmod +x "$LAUNCHER"

# Create .desktop file
echo "Creating desktop entry at $DESKTOP_FILE..."
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$COMMENT
Exec=$LAUNCHER
Icon=$ICON_PATH
Type=Application
Categories=Network;Internet;VPN
MimeType=application/x-desktop;
Terminal=false
EOF

echo "Installation complete! You can launch Nekoray from your application menu or by running 'nekolaunch'."

# Cleanup
rm -rf "$TMP_DIR"
