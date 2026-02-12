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

if [ -d "$GO_DIR" ];then
  echo "Removing old Go installation... "
  sudo rm -rf "$GO_DIR"
fi

echo "Extracting to $INSTALL_DIR ..."
sudo tar -C "$INSTALL_DIR" -xzf "$TMP_FILE"

rm -f "$TMP_FILE"

echo "Go installed successfully."

add_go_to_path() {
    SHELL_NAME=$1
    CONFIG_FILE=$2
    SHELL_COMMENT=$3

    if [ -f "$CONFIG_FILE" ]; then
        if ! grep -q '/usr/local/go/bin' "$CONFIG_FILE"; then
            echo ""
            echo "Adding /usr/local/go/bin to $SHELL_NAME config ($CONFIG_FILE)..."
            echo '' >> "$CONFIG_FILE"
            echo "# Added by GoUp: $SHELL_COMMENT" >> "$CONFIG_FILE"
            if [ "$SHELL_NAME" = "fish" ]; then
                echo 'set -gx PATH $PATH /usr/local/go/bin' >> "$CONFIG_FILE"
                # more modern version (v4+)
                #echo 'fish_add_path -U /usr/local/go/bin' >> "$CONFIG_FILE"
            else
                echo 'export PATH=$PATH:/usr/local/go/bin' >> "$CONFIG_FILE"
            fi
            #echo "Reloading config to use updated PATH..."
            #source $CONFIG_FILE;
            echo "Done. Please restart your $SHELL_NAME shell to update PATH."
        else
            echo "$SHELL_NAME config already has Go in PATH"
        fi

        # Go workspace
        if ! grep -q "$HOME/go/bin" "$CONFIG_FILE"; then
            echo ""
            echo "Adding $HOME/go/bin to $SHELL_NAME config ($CONFIG_FILE)..."
            echo '' >> "$CONFIG_FILE"
            echo "# Added by GoUp: $SHELL_COMMENT" >> "$CONFIG_FILE"
            if [ "$SHELL_NAME" = "fish" ]; then
                echo 'set -gx GOPATH $HOME/go' >> "$CONFIG_FILE"
                echo 'set -gx PATH $PATH $GOPATH/bin' >> "$CONFIG_FILE"
                # more modern version (v4+)
                #echo 'fish_add_path -U $HOME/go/bin' >> "$CONFIG_FILE"
            else
                echo 'export GOPATH=$HOME/go' >> "$CONFIG_FILE"
                echo 'export PATH=$PATH:$GOPATH/bin' >> "$CONFIG_FILE"
            fi
            #echo "Reloading config to use updated PATH..."
            #source $CONFIG_FILE;
            echo "Done. Please restart your $SHELL_NAME shell to update PATH."
        else
            echo "$SHELL_NAME config already has Go workspace in PATH"
        fi
    else
        echo "Warning: $SHELL_NAME config file $CONFIG_FILE not found. You may need to add Go to PATH manually."
    fi
}

echo "setup Go workspace..."
if [ ! -e "$HOME/go/bin" ]; then
  mkdir -p "$HOME/go/bin";
fi
if [ ! -e "$HOME/go/src" ]; then
  mkdir -p "$HOME/go/src";
fi
if [ ! -e "$HOME/go/pkg" ]; then
  mkdir -p "$HOME/go/pkg";
fi

# -------- Check bash --------
if command -v bash >/dev/null 2>&1; then
    if [ -f "$HOME/.bashrc" ]; then
        add_go_to_path "bash" "$HOME/.bashrc" "bashrc"
    elif [ -f "$HOME/.profile" ]; then
        add_go_to_path "bash" "$HOME/.profile" "profile"
    fi
fi

# -------- Check zsh --------
if command -v zsh >/dev/null 2>&1; then
    if [ -f "$HOME/.zshrc" ]; then
        add_go_to_path "zsh" "$HOME/.zshrc" "zshrc"
    fi
fi

# -------- Check fish --------
if command -v fish >/dev/null 2>&1; then
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    add_go_to_path "fish" "$FISH_CONFIG" "config.fish"
fi

echo ""
echo "Installed version:"
"$GO_DIR/bin/go" version
