#!/usr/bin/env bash
set -e

# Configurable variables
REPO="throneproj/Throne"
ASSET_SUFFIX="linux64.zip"
INSTALL_DIR="$HOME/Apps"
APP_DIR="$INSTALL_DIR/nekoray"
LAUNCHER="$HOME/.local/bin/nekolaunch"
DESKTOP_FILE="$HOME/.local/share/applications/nekoray.desktop"
ICON_PATH="$APP_DIR/nekobox.png"
APP_NAME="Nekoray VPN"
COMMENT="NekoRay VPN (V2ray Application)"
CONFIG_DIR="$APP_DIR/config"
SUBSCRIPTIONS_JSON_URL="https://raw.githubusercontent.com/ahmz1833/nekoray-downloader/main/subscriptions.json"
NEKOBOX_JSON_URL="https://raw.githubusercontent.com/ahmz1833/nekoray-downloader/main/nekobox.json"

# Ensure required tools
for cmd in jq curl unzip; do
	if ! command -v "$cmd" &>/dev/null; then
		echo "Error: $cmd is required but not installed." >&2
		exit 1
	fi
done

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

NO_DOWNLOAD=false
VERSION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		--no-download)
			NO_DOWNLOAD=true
			shift # past argument
			;;
		*)
			# unknown option, assume it's the version
			VERSION="$1"
			shift # past argument
			;;
	esac
done

# Create temp dir
TMP_DIR=$(mktemp -d)

if [ "$NO_DOWNLOAD" = false ]; then
	if [ -d "$APP_DIR" ]; then
		echo "App directory already exists at $APP_DIR"
		read -p "Do you want to overwrite it? [y/N]: " confirm
		if [[ "$confirm" =~ ^[Yy]$ ]]; then
			rm -rf "$APP_DIR"
		else
			echo "Aborted by user."
			rm -rf "$TMP_DIR"
			exit 0
		fi
	fi
	cd "$TMP_DIR"
	download_nekoray "$VERSION"
	ZIP_FILE=*.zip
	mkdir -p "$INSTALL_DIR"
	echo "Extracting to $INSTALL_DIR..."
	unzip -q "$ZIP_FILE" -d "$INSTALL_DIR"
else
	echo "Skipping download and extraction due to --no-download flag."
fi

if [ ! -d "$APP_DIR" ]; then
	echo "Error: Expected folder $APP_DIR not found."
	exit 1
fi

# Install configs dynamically from external JSON
sudo rm -rf "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/groups"
echo "Downloading subscriptions JSON..."
curl -s -o "$TMP_DIR/subscriptions.json" "$SUBSCRIPTIONS_JSON_URL"

GROUP_IDS=()
i=0
while IFS=':::' read -r NAME URL; do
	# Remove leading :: if present
	URL=${URL#::}
	cat > "$CONFIG_DIR/groups/$i.json" <<EOF
{
	"id": $i,
	"info": "",
	"name": "$NAME",
	"url": "$URL"
}
EOF
	GROUP_IDS+=("$i")
	i=$((i+1))
done < <(jq -r 'to_entries[] | "\(.key):::\(.value)"' "$TMP_DIR/subscriptions.json")

# Create pm.json dynamically
GROUP_IDS_JOINED=$(printf ",%s" "${GROUP_IDS[@]}")
GROUP_IDS_JOINED="${GROUP_IDS_JOINED:1}"
cat > "$CONFIG_DIR/groups/pm.json" <<EOF
{
	"groups": [${GROUP_IDS_JOINED}]
}
EOF

echo "Downloading nekobox.json..."
curl -s -o "$CONFIG_DIR/groups/nekobox.json" "$NEKOBOX_JSON_URL"

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	echo "Adding ~/.local/bin to PATH for this session..."
	export PATH="$HOME/.local/bin:$PATH"
	
	# Add to shell profile if it doesn't exist
	SHELL_PROFILE=""
	if [ -f "$HOME/.bashrc" ]; then
		SHELL_PROFILE="$HOME/.bashrc"
	elif [ -f "$HOME/.zshrc" ]; then
		SHELL_PROFILE="$HOME/.zshrc"
	elif [ -f "$HOME/.profile" ]; then
		SHELL_PROFILE="$HOME/.profile"
	fi
	
	if [ -n "$SHELL_PROFILE" ] && ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_PROFILE"; then
		echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_PROFILE"
		echo "Added ~/.local/bin to PATH in $SHELL_PROFILE"
		echo "Please restart your shell or run 'source $SHELL_PROFILE' to make it permanent."
	fi
fi

# Create launcher script
mkdir -p "$(dirname "$LAUNCHER")"
cat > "$LAUNCHER" <<EOF
#!/bin/sh
pkexec env DISPLAY=\$DISPLAY XAUTHORITY=\$XAUTHORITY "$APP_DIR/nekoray"
EOF
chmod +x "$LAUNCHER"

# Create desktop file
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

rm -rf "$TMP_DIR"
