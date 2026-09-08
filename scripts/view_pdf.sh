#!/usr/bin/env bash
PDF="$1"

if [ ! -f "$PDF" ]; then
    echo "File not found: $PDF"
    exit 1
fi

# If kitty is not running or available, fallback to text pager directly
if ! command -v kitty >/dev/null 2>&1; then
    exec pdftotext -layout "$PDF" - | less -R
fi

# Get total page count using pdfinfo (part of poppler)
TOTAL_PAGES=1
if command -v pdfinfo >/dev/null 2>&1; then
    INFO_PAGES=$(pdfinfo "$PDF" 2>/dev/null | awk '/^Pages:/ {print $2}')
    [ -n "$INFO_PAGES" ] && TOTAL_PAGES="$INFO_PAGES"
fi

PAGE=1
TMP_IMG="/tmp/tmux_pdf_view_$$"

cleanup() {
    rm -f "${TMP_IMG}"*
    clear
}
trap cleanup EXIT INT TERM

render_page() {
    clear
    echo -e "\033[1;34m[PDF Viewer]\033[0m Page \033[1m$PAGE\033[0m of \033[1m$TOTAL_PAGES\033[0m | [j/n] Next | [k/p] Prev | [t] Text mode | [q] Quit"
    echo "──────────────────────────────────────────────────────────────────"
    pdftoppm -jpeg -scale-to 1200 -f "$PAGE" -l "$PAGE" -singlefile "$PDF" "$TMP_IMG" 2>/dev/null
    if [ -f "${TMP_IMG}.jpg" ]; then
        kitty +kitten icat --stdin no --silent --transfer-mode file "${TMP_IMG}.jpg" 2>/dev/null
    fi
}

while true; do
    render_page
    # Read single keystroke
    read -r -s -n 1 key
    case "$key" in
        j|n|" ")
            if [ "$PAGE" -lt "$TOTAL_PAGES" ]; then
                PAGE=$((PAGE + 1))
            fi
            ;;
        k|p)
            if [ "$PAGE" -gt 1 ]; then
                PAGE=$((PAGE - 1))
            fi
            ;;
        t|T)
            pdftotext -layout "$PDF" - | less -R
            ;;
        q|Q)
            break
            ;;
        g)
            PAGE=1
            ;;
        G)
            PAGE=$TOTAL_PAGES
            ;;
    esac
done
