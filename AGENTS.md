# Repository Guidelines

## Project Overview

Personal dotfiles for an Arch + Hyprland + Omarchy desktop. Omarchy (submodule `omarchy/.local/share/omarchy`, v3.8.0) is the install system and theme engine; this repo is the user layer on top of it: shell setup, Hyprland/waybar/walker/terminal config, personal scripts, and the active-theme state.

The repo is a plain git checkout deployed live via GNU Stow. It contains seven stow packages (top-level dirs), each mirroring a slice of `$HOME`. Edit a file, commit, re-stow - the running system changes directly. No build system, no CI, no test framework.

- Remote: `github.com/skraikov/dotfiles`, branch `main`
- 177 tracked files: seven packages + root `.gitmodules`

## Architecture & Data Flow

```
~/.dotfiles (plain git checkout, branch main)
+- shell/     .zshrc  .profile  .config/zsh/oh-my-zsh (submodule)
+- wayland/   .config/{hypr,waybar,walker,fuzzel,alacritty,uwsm}  xdg-terminals.list
+- omarchy/   .local/share/omarchy (submodule)  .config/omarchy/ (active theme state)
+- tools/     .local/bin/  .config/git/
+- security/  .config/gnupg/  .config/gopass/  .gnupg (symlink)
+- agent/     .config/opencode/
+- x11/       .config/{awesome,xserver,mplayer}  .xprofile
'- .gitmodules

        stow -d ~/.dotfiles -t ~ shell wayland omarchy tools security agent x11
                |
                v
$HOME:   ~/.zshrc -> .dotfiles/shell/.zshrc
         ~/.config/hypr/*.conf -> ../../.dotfiles/wayland/.config/hypr/*.conf
         submodules -> directory-level symlinks (~/.local/share/omarchy)
```

Package rules (load-bearing, verified by history):

- Packages are flat, one level under the repo root, and their contents use the exact `$HOME`-relative paths (`wayland/.config/hypr/...`, never `wayland/hypr/...`). This keeps the two in-repo symlink targets byte-stable: `security/.gnupg -> ../../.config/gnupg` (2 ascents = `$HOME`) and `omarchy/.config/omarchy/current/background` (5 ascents = `$HOME`). Nesting packages deeper breaks them.
- `git mv a/b c/` with multiple sources flattens (`a/b` lands at `c/b`). Always spell out full destinations.
- Plain `stow` silently skips links that already point anywhere into the stow dir, even stale/dangling ones. After moving files between packages, run `stow -R <pkg>`, not `stow <pkg>`.

Hyprland config precedence - `source =` order in `wayland/.config/hypr/hyprland.conf`, later wins:

1. Omarchy defaults `~/.local/share/omarchy/default/hypr/*.conf` (submodule, "don't edit directly")
2. Active theme `~/.config/omarchy/current/theme/hyprland.conf` (generated; defines `$activeBorderColor`; must be sourced before consumers like `hyprlock.conf`)
3. User layer `~/.config/hypr/{monitors,input,bindings.conf,looknfeel,autostart}.conf` + `bindings/*.conf`

Theme data flow: `omarchy-theme-set <name>` copies the theme + user overrides, renders `default/themed/*.tpl`, atomically replaces `current/theme/`, writes `theme.name`, restarts components. Wallpaper: the `current/background` symlink, rewritten by `omarchy-theme-bg-set/-next`, consumed by swaybg and hyprlock.

## Key Directories

| Package | Contents and purpose |
|---|---|
| `shell/` | `.zshrc` (omz via `ZSH=$HOME/.config/zsh/oh-my-zsh`, sources `/etc/profile` + `.profile` before the interactive gate, starship last), `.profile` (XDG_*, EDITOR=nvim, SSH_AUTH_SOCK), oh-my-zsh submodule |
| `wayland/` | User Hyprland layer (`hypr/` incl. per-concern `bindings/*.conf`, `monitors.conf` DP-4+HDMI-A-2), waybar, walker, fuzzel, alacritty, uwsm session env (`OMARCHY_PATH`, PATH), `xdg-terminals.list` |
| `omarchy/` | Submodule (default/, bin/ ~200 `omarchy-*` commands, themes/, install/, migrations/) + `.config/omarchy/`: `current/` active theme state (mostly generated, do not hand-edit), `hooks/` (`.sample` = inactive), `themed/` user templates, `extensions/` |
| `tools/` | `.local/bin/`: `enter-password-{fuzzel,rofi,walker}{,-otp}.sh` (gopass -> picker --dmenu -> ydotool type), `exifcopy/` python tools (venv untracked + gitignored), `docker-cleanup.sh`, `lvmcache-stats`, `run-vm.sh`, monkeysphere `keytrans` + `openpgp2ssh`/`pem2openpgp` symlinks; `.config/git/` global git config |
| `security/` | `.config/gnupg/` (gpg-agent 12h cache), `.config/gopass/` + jsonapi wrapper, `.gnupg` symlink redirecting GPG home to `~/.config/gnupg` |
| `agent/` | opencode AI-agent config: `opencode.json` (providers, superpowers plugin, disabled MCP servers), `tui.json`, `plugins/rtk.ts` |
| `x11/` | Legacy X11: awesome WM (89 files), xserver xdefaults/xmodmap (xmodmap defines Mod5=Hyper from CapsLock - Hyprland binds depend on it), mplayer (`vo=xv`), `.xprofile` |

## Development Commands

There is no build, lint, or test command. Deploy = stow; test = the live system.

```sh
# Deploy / re-deploy (idempotent; -n for dry run)
stow -d /home/skraikov/.dotfiles -t /home/skraikov shell wayland omarchy tools security agent x11
# Unstow one package (e.g. drop the X11 legacy)
stow -D -d /home/skraikov/.dotfiles -t /home/skraikov x11
# Restow after moving files between packages (fixes stale links; plain stow skips them)
stow -R -d /home/skraikov/.dotfiles -t /home/skraikov <pkg>

# Add a new dotfile: write <pkg>/<home-relative-path>, commit, re-run stow.
# Example: tools/.config/ripgrep/config  ->  ~/.config/ripgrep/config

# Verify changes live
hyprctl reload                  # Hyprland config
exec zsh                        # shell rc changes
readlink -f ~/.gnupg            # symlink integrity

# Submodules (pins: oh-my-zsh c5f64018, omarchy b2d95ee2)
git submodule update --init --recursive
# bump: pull inside the submodule, checkout the pin, then in the superproject:
#   git add omarchy/.local/share/omarchy  ->  commit "chore: update omarchy submodule to <short-hash>"

# Omarchy runtime (on PATH in a session via wayland/.config/uwsm/env)
omarchy-theme-set <name>   omarchy-theme-bg-next   omarchy update   omarchy debug
omarchy commands --check   # only when touching the omarchy submodule
# Do NOT casually re-run ~/.local/share/omarchy/install.sh - full fresh-machine installer
```

## Code Conventions & Common Patterns

- Never hand-edit generated state: `omarchy/.config/omarchy/current/theme/*` and `current/background` are rewritten by omarchy. Durable theming goes in `~/.config/omarchy/themes/<name>/` or `omarchy/.config/omarchy/themed/*.tpl` (rename `.sample` to activate).
- Never edit submodule files as user config; user overrides live in the package layer. In-place submodule edits show as ` M omarchy/.local/share/omarchy` drift.
- Hyprland: `source` order is precedence; theme files before consumers; optional theme sources guarded by `# hyprlang noerror true/false`; `$mainMod = MOD5` is re-declared at the top of every `bindings/*.conf`; digit binds use `code:10`-`code:19`; launch apps only through `uwsm-app -- ...`, `omarchy-launch-*`, `xdg-terminal-exec` so they inherit OMARCHY_PATH/TERMINAL/EDITOR.
- Shell layering: `.profile` = non-interactive env, sourced by zsh before the interactive gate; `.zshrc` = omz, aliases, starship (last line); `.xprofile` = X11-only bootstrap.
- Scripts: `enter-password-*` are bash one-liner pipelines sharing one shape (deps: gopass, picker, ydotool; no guards, deps assumed on PATH); strict `set -euo pipefail` sh for utilities; `exifcopy/` runs from an untracked venv (`pip install -r requirements.txt`; note pyexiv2 is missing from it).
- Git: scopeless Conventional Commits (`fix:`, `chore:`, `test:`, `refactor:`, `docs:`); older history uses `<domain>:` prefixes (`hypr:`, `zsh:`). Submodule bumps record the pinned short hash.
- Stow/symlinks: any symlink stored inside a package must have a relative target, computed from the link's own directory. Empty dirs use `.keep`.

## Important Files

| File | Why it matters |
|---|---|
| `wayland/.config/hypr/hyprland.conf` | Entry point; 3-layer source chain; omarchy stock binding sources commented out in favor of own `bindings/*.conf` |
| `wayland/.config/hypr/bindings.conf` | Reference for wrapper usage and the per-file `$mainMod = MOD5` pattern |
| `shell/.zshrc` | Main shell config; contains stale `dotfiles`/`dotfiles-lg` aliases (old bare-repo layout) and an `omarhy` PATH typo - don't replicate |
| `omarchy/.config/omarchy/current/theme.name` | Active theme (`catppuccin`); `current/` is the tracked snapshot of runtime theme state |
| `security/.gnupg` | Tracked symlink `-> ../../.config/gnupg` (XDG-redirected GPG home; live key material sits in that stow-managed dir - never `git add` untracked files there) |
| `agent/.config/opencode/opencode.json` | AI-agent config. Contains plaintext API tokens - never echo, commit, or propagate them |
| `.gitmodules` | Two submodules; omarchy is the whole desktop platform, deployed in place |

## Runtime/Tooling Preferences

- Live machine is the deploy target: GNU Stow 2.4.1 + git required; `hyprctl` for the running Wayland/Hyprland session; `omarchy` CLI comes from the submodule's `bin/`.
- zsh + oh-my-zsh + starship; python tools use a local venv; no repo-level package manager or build tooling.
- Wayland first; `x11/` is legacy but retained for X sessions/VMs. Exception: `x11/.config/xserver/xmodmap` defines the Mod5/Hyper key Hyprland binds rely on.
- `agent/.config/opencode/plugins/rtk.ts` rewrites shell commands for token efficiency via the external `rtk` CLI (>= 0.23.0); rewrite rules live in the rtk Rust registry, not this file.

## Testing & QA

No automated checks exist (no shellcheck/luacheck/CI; none installed). Verification is empirical on the live system:

1. Edit under a package, re-stow, `hyprctl reload` / new shell, observe, fix, commit. Symlink-depth bugs were caught exactly this way in history (`e1d580e` fixed at runtime by `10cc024` six minutes later).
2. Provtest canary pattern (validates the repo -> `$HOME` pipeline end-to-end): commit a tiny `<pkg>/.config/provtest/provtest.conf`, stow, confirm it lands in `$HOME` with exact content, then commit the removal. Used for this layout too (`b33b2e5` -> `88cc5b2`); canaries from two packages merge into the same live dir. Remove orphan links manually - `stow -D` cannot see files already deleted from the package.
3. Fresh-machine proof: clean clone, `git submodule update --init --recursive`, stow all seven packages into an empty target dir, sweep that every tracked file resolves. Only `background` and `.gnupg` may dangle there - their targets anchor to the real `$HOME`.
4. `stow -n` dry-run per package must be a no-op after any deploy.

Expected `git status` noise (known live drift, decide before committing): ` M agent/.config/opencode/opencode.json` (tracked copy pins `ollama/dolphin3:latest`; live copy re-pointed at an `rwb` provider) and ` M omarchy/.local/share/omarchy` (local `default/hypr/looknfeel.conf` tweak, deliberately uncommitted).

Known stale items: `shell/.zshrc` `dotfiles`/`dotfiles-lg` aliases reference the removed `~/.dotfiles.git` layout; `tools/.local/bin/run-vm.sh` hardcodes `/home/serge/...`; `tools/.local/bin/exifcopy/requirements.txt` is missing pyexiv2; `tools/.config/git/config` carries Cygwin-era difftool entries.

Security: plaintext secrets (JWT API keys, Jira/GitLab tokens) exist in `agent/.config/opencode/opencode.json` and its git history - treat as compromised if the repo is ever shared. Never stage GPG key material from the live `~/.gnupg` (resolves into `~/.config/gnupg`) directory.
