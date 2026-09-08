#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="$1"

# If no target specified, open yazi or lf or pick file
if [ -z "$TARGET" ]; then
    if command -v yazi >/dev/null 2>&1; then
        exec yazi
    elif command -v lf >/dev/null 2>&1; then
        exec lf
    else
        exec "$DIR/pick_and_view.sh"
    fi
fi

# If target is directory, open yazi or lf
if [ -d "$TARGET" ]; then
    if command -v yazi >/dev/null 2>&1; then
        exec yazi "$TARGET"
    else
        exec lf "$TARGET"
    fi
fi

# Detect extension
EXT="${TARGET##*.}"
EXT="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

case "$EXT" in
    md|markdown)
        if command -v glow >/dev/null 2>&1; then
            exec glow "$TARGET" -p
        else
            exec less -R "$TARGET"
        fi
        ;;
    pdf)
        exec "$DIR/view_pdf.sh" "$TARGET"
        ;;
    png|jpg|jpeg|gif|webp|svg)
        if command -v kitty >/dev/null 2>&1; then
            clear
            kitty +kitten icat --stdin no --hold "$TARGET"
        else
            echo "Unsupported image viewer without kitty."
            read -n 1
        fi
        ;;
    *)
        if command -v bat >/dev/null 2>&1; then
            exec bat "$TARGET"
        else
            exec less -R "$TARGET"
        fi
        ;;
esac
