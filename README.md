# tmux Configuration

Modular tmux configuration tailored for Neovim integration, Kitty terminal, and Catppuccin theme.

## Kitty Terminal Configuration

Kitty maps `Ctrl+Shift+h` and `Ctrl+Shift+l` by default for internal actions (such as scrollback or layout switching). Because Kitty captures these shortcuts before forwarding them to applications, tmux cannot receive them unless Kitty's default shortcuts are disabled.

To enable seamless pane navigation with `Ctrl+Shift+h` and `Ctrl+Shift+l`, add the following lines to your `kitty.conf` (e.g., `~/.config/kitty/kitty.conf`):

```kitty
map ctrl+shift+h no_op
map ctrl+shift+l no_op
```

> [!NOTE]
> tmux is configured with extended keys enabled (`set -s extended-keys always` and `set -as terminal-features 'xterm-kitty:extkeys'`) so that modified key sequences like `Ctrl+Shift+h/j/k/l` are passed cleanly between Kitty, tmux, and Neovim (`vim-tmux-navigator`).

---

## Modular File Structure

- [tmux.conf](file:///home/angshuman/.config/tmux/tmux.conf) - Entrypoint sourcing configuration modules.
- [options.conf](file:///home/angshuman/.config/tmux/options.conf) - General tmux options, terminal features, clipboard, and extended keys.
- [keymaps.conf](file:///home/angshuman/.config/tmux/keymaps.conf) - Keybindings (navigation, splits, popups, pane stashing).
- [plugins.conf](file:///home/angshuman/.config/tmux/plugins.conf) - TPM and plugin declarations (Catppuccin, Resurrect, Continuum).
- [statusbar.conf](file:///home/angshuman/.config/tmux/statusbar.conf) - Status bar layout and styling.
- [scripts/](file:///home/angshuman/.config/tmux/scripts) - Helper scripts for doc viewers, pane stashing, and automated plugin installation.

---

## Keybindings

### Navigation (Seamless tmux + Neovim)
| Key | Action |
| --- | --- |
| `Ctrl+Shift+h` | Focus pane to the left |
| `Ctrl+Shift+j` | Focus pane down |
| `Ctrl+Shift+k` | Focus pane up |
| `Ctrl+Shift+l` | Focus pane to the right |
| `Ctrl+Shift+\` | Focus previous pane |

*(Falls back to Vim-style prefix navigation: `<prefix> h / j / k / l`)*

### Pane Resizing
| Key | Action |
| --- | --- |
| `<prefix> H` | Resize pane left by 5 cells |
| `<prefix> J` | Resize pane down by 5 cells |
| `<prefix> K` | Resize pane up by 5 cells |
| `<prefix> L` | Resize pane right by 5 cells |

### Panes & Windows
| Key | Action |
| --- | --- |
| `<prefix> %` | Split pane horizontally (current path) |
| `<prefix> "` | Split pane vertically (current path) |
| `<prefix> -` | Stash / hide active pane |
| `<prefix> +` | Pop last stashed pane |
| `<prefix> =` | Show menu of stashed panes |

### Document Viewer Popups
| Key | Action |
| --- | --- |
| `<prefix> o` | View active document / file in popup |
| `<prefix> O` | Pick and view file via fzf in popup |

### Config Reload
| Key | Action |
| --- | --- |
| `<prefix> r` | Reload `~/.config/tmux/tmux.conf` |
