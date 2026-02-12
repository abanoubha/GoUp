#!/bin/env sh

set -eu

INSTALL_DIR="/usr/local"
GO_DIR="$INSTALL_DIR/go"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64";;
  aarch64) ARCH="arm64";;
  armv6l) ARCH="armv6l";;
  armv7l) ARCH="armv6l";;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

OS=$(uname | tr '[:upper:]' '[:lower:]')

echo "Fetching latest Go version..."
if command -v curl > /dev/null 2>&1;then
  LATEST=$(curl -fsSL https://go.dev/VERSION?m=text | head -n 1)
elif command -v wget > /dev/null 2>&1;then
  LATEST=$(wget -qO- https://go.dev/VERSION?m=text | head -n 1)
else
  echo "Error: curl or wget is required YET NOT FOUND!"
  exit 1
fi

echo "Latest version: $LATEST"

if [ -x "$GO_DIR/bin/go" ];then
  INSTALLED=$("$GO_DIR/bin/go" version | awk '{print $3}')
  echo "Installed version: $INSTALLED"
else
  INSTALLED=""
  echo "No existing Go installation found."
fi

if [ "$INSTALLED" = "$LATEST" ];then
  echo "Go is already up to date. Nothing to do."
  exit 0
fi

echo "Installing $LATEST ..."

TARBALL="$LATEST.$OS-$ARCH.tar.gz"
URL="https://go.dev/dl/$TARBALL"

TMP_FILE="/tmp/$TARBALL"

echo "Downloading $URL ..."
if command -v curl > /dev/null 2>&1;then
  curl -fSL "$URL" -o "$TMP_FILE"
else
  wget -O "$TMP_FILE" "$URL"
fi

echo "Removing old Go installation (if any) ... "
if [ -d "$GO_DIR" ];then
  sudo rm -rf "$GO_DIR"
fi

echo "Extracting to $INSTALL_DIR ..."
sudo tar -C "$INSTALL_DIR" -xzf "$TMP_FILE"

rm -f "$TMP_FILE"

echo "Go installed successfully."

if echo "$PATH" | grep -q "$GO_DIR/bin";then
  :
else
  echo ""
  echo "WARNING: $GO_DIR/bin is not in your PATH."
  echo "Add this line to your profile (~/.profile or ~/.bashrc):"
  echo "export PATH=\$PATH:$GO_DIR/bin"
fi

echo ""
echo "Installed version:"
"$GO_DIR/bin/go" version
