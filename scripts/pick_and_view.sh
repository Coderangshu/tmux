#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure fzf / yazi exist
if ! command -v fzf >/dev/null 2>&1 || ! command -v yazi >/dev/null 2>&1; then
    "$DIR/ensure_tools.sh"
fi

# Pick file with fzf in current directory
SELECTED="$(fzf --prompt="Select file > " --header="Dir: $(pwd)" --reverse)"

if [ -n "$SELECTED" ]; then
    exec "$DIR/view_doc.sh" "$SELECTED"
fi
