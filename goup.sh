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
CHECKSUM_URL="https://go.dev/dl/$LATEST.$OS-$ARCH.tar.gz.sha256"

TMP_FILE="/tmp/$TARBALL"
TMP_SUM="/tmp/$TARBALL.sha256"

echo "Downloading $URL ..."
if command -v curl > /dev/null 2>&1;then
  curl -fSL "$URL" -o "$TMP_FILE"
  curl -fSL "$CHECKSUM_URL" -o "$TMP_SUM"
else
  wget -O "$TMP_FILE" "$URL"
  wget -O "$TMP_SUM" "$CHECKSUM_URL"
fi

echo "verifying SHA256 checksum ..."

EXPECTED=$(cat "$TMP_SUM" | awk '{print $1}')

if command -v sha256sum > /dev/null 2>&1;then
  ACTUAL=$(sha256sum "$TMP_FILE" | awk '{print $1}')
elif command -v shasum > /dev/null 2>&1;then
  ACTUAL=$(shasum -a 256 "$TMP_FILE" | awk '{print $1}')
else
  echo "Error: sha256sum or shasum is required YET NOT FOUND!"
  exit 1
fi

if [ "$EXPECTED" != "$ACTUAL" ];then
  echo "Checksum verification FAILED!"
  echo "Expected: $EXPECTED"
  echo "Actual: $ACTUAL"
  rm -f "$TMP_FILE" "$TMP_SUM"
  exit 1
fi

echo "Checksum verified."

if [ -d "$GO_DIR" ];then
  echo "Removing old Go installation... "
  sudo rm -rf "$GO_DIR"
fi

echo "Extracting to $INSTALL_DIR ..."
sudo tar -C "$INSTALL_DIR" -xzf "$TMP_FILE"

rm -f "$TMP_FILE" "$TMP_SUM"

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
