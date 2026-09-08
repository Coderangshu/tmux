#!/usr/bin/env bash
# Stash (hide), pop, and menu-pick panes in tmux

ACTION="$1" # "hide", "pop", or "menu"
STASH_PREFIX="_stash"

# Target active pane and its window/session context
CURRENT_PANE="${TMUX_PANE}"
if [ -z "$CURRENT_PANE" ]; then
    CURRENT_PANE=$(tmux display-message -p '#{pane_id}')
fi

CURRENT_SESSION=$(tmux display-message -p -t "$CURRENT_PANE" '#{session_id}')
PANES_IN_WINDOW=$(tmux display-message -p -t "$CURRENT_PANE" '#{window_panes}')

case "$ACTION" in
    hide)
        if [ "$PANES_IN_WINDOW" -le 1 ]; then
            tmux display-message "Cannot hide only pane in window"
            exit 0
        fi
        tmux break-pane -d -n "$STASH_PREFIX" -s "$CURRENT_PANE" -t "$CURRENT_SESSION:"
        tmux display-message "Pane hidden to stash"
        ;;

    pop)
        # Find latest stash window in current session (LIFO order)
        TARGET_WINDOW_ID=$(tmux list-windows -t "$CURRENT_SESSION" -F '#{window_id} #{window_name}' | awk "\$2 ~ /^${STASH_PREFIX}/ {print \$1}" | tail -n 1)

        if [ -n "$TARGET_WINDOW_ID" ]; then
            tmux join-pane -h -t "$CURRENT_PANE" -s "$TARGET_WINDOW_ID"
            tmux display-message "Pane restored from stash"
        else
            tmux display-message "Stash is empty"
        fi
        ;;

    menu)
        MENU_ARGS=("-T" "Stashed Panes" "-t" "$CURRENT_PANE" "-x" "C" "-y" "C")
        count=0
        i=1
        while read -r wid wname pcmd ptitle; do
            [ -z "$wid" ] && continue
            label="[$pcmd] ${ptitle:-stash}"
            # Truncate label if too long
            label="${label:0:40}"
            MENU_ARGS+=("$i) $label" "$i" "join-pane -h -t '$CURRENT_PANE' -s '$wid'")
            ((i++))
            ((count++))
        done < <(tmux list-windows -t "$CURRENT_SESSION" -F '#{window_id} #{window_name} #{pane_current_command} #{pane_title}' | awk '$2 ~ /^_stash/')

        if [ "$count" -eq 0 ]; then
            tmux display-message "Stash is empty"
            exit 0
        fi

        tmux display-menu "${MENU_ARGS[@]}"
        ;;

    *)
        echo "Usage: $0 {hide|pop|menu}" >&2
        exit 1
        ;;
esac
