#!/usr/bin/env bash
set -e

OS="$(uname -s)"
DISTRO=""
if [ "$OS" = "Linux" ] && [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
fi

install_tools() {
    echo "==> Missing tools detected ($MISSING). Installing for $OS ($DISTRO)..."
    case "$OS" in
        Darwin)
            if ! command -v brew >/dev/null 2>&1; then
                echo "Error: Homebrew missing. Install brew first." >&2
                exit 1
            fi
            brew install fzf glow yazi poppler
            ;;
        Linux)
            case "$DISTRO" in
                arch|manjaro|endeavouros)
                    if command -v paru >/dev/null 2>&1; then
                        paru -S --needed --noconfirm fzf glow yazi poppler
                    elif command -v yay >/dev/null 2>&1; then
                        yay -S --needed --noconfirm fzf glow yazi poppler
                    else
                        sudo pacman -S --needed --noconfirm fzf glow yazi poppler
                    fi
                    ;;
                ubuntu|debian|pop|mint)
                    sudo apt-get update
                    sudo apt-get install -y fzf poppler-utils
                    if ! command -v glow >/dev/null 2>&1; then
                        sudo mkdir -p /etc/apt/keyrings
                        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg --yes
                        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                        sudo apt-get update && sudo apt-get install -y glow
                    fi
                    if ! command -v yazi >/dev/null 2>&1; then
                        echo "Downloading latest yazi binary..."
                        curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | \
                            grep "browser_download_url.*x86_64-unknown-linux-musl.zip" | \
                            cut -d : -f 2,3 | tr -d \" | wget -qi - -O /tmp/yazi.zip
                        unzip -q -o /tmp/yazi.zip -d /tmp/
                        sudo mv /tmp/yazi-*-linux-musl/yazi /usr/local/bin/
                        rm -rf /tmp/yazi*
                    fi
                    ;;
                fedora)
                    sudo dnf install -y fzf glow yazi poppler-utils
                    ;;
                *)
                    echo "Unsupported Linux distro: $DISTRO" >&2
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $OS" >&2
            exit 1
            ;;
    esac
    echo "==> Setup complete."
}

# Check all required tools
MISSING=""
for tool in fzf glow pdftotext; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING="$MISSING $tool"
    fi
done

if [ -n "$MISSING" ]; then
    install_tools
fi
