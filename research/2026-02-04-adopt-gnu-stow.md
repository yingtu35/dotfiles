---
date: 2026-02-04T12:00:00+00:00
git_commit: HEAD
branch: current
repository: .dotfiles
topic: "Current Dotfiles Symlink Management"
tags: [research, dotfiles, symlinks, zsh, mackup]
status: complete
last_updated: 2026-02-04
last_updated_note: "Incorporated user clarifications regarding aliases.zsh, path.zsh, and unmanaged files."
---

# Research: Current Dotfiles Symlink Management

**Date**: 2026-02-04
**Repository**: .dotfiles

## Research Question
"I'd like to adopt gnu-stow symlink farm manager tool to easily symlink all dotfiles in the repo."
*(Research focuses on documenting the current symlinking mechanisms to support this request.)*

## Summary
The repository currently utilizes a hybrid approach for configuration management. It relies on a shell script (`fresh.sh`) for manual symlinking of core shell configuration and `mackup` for restoring application-specific settings from cloud storage. A significant number of dotfiles located in the root directory (`.gitconfig`, `.tmux.conf`, etc.) are present but are not currently targeted by the automated installation script.

## Detailed Findings

### 1. Automated Symlinking (`fresh.sh`)
The `fresh.sh` script handles the installation of command-line tools and explicitly symlinks only two configuration files:
- **`~/.zshrc`**: The script removes any existing `.zshrc` in the home directory and creates a symbolic link pointing to `.dotfiles/.zshrc`.
- **`~/.mackup.cfg`**: The script creates a symbolic link from `.dotfiles/.mackup.cfg` to the home directory.

### 2. Mackup Configuration
- **Mechanism**: The repository uses `mackup` to sync application settings.
- **Configuration**: The `.mackup.cfg` file is configured to use iCloud as the storage engine.
- **Exclusions**: It explicitly ignores `zsh`, delegating that management to the `fresh.sh` script.

### 3. File Inventory & Status
The following configuration files exist in the repository root:

| File | Management Status |
| :--- | :--- |
| `.zshrc` | **Symlinked** by `fresh.sh`. |
| `.mackup.cfg` | **Symlinked** by `fresh.sh`. |
| `.p10k.zsh` | **Unmanaged** by `fresh.sh`. Sourced by `.zshrc` if present in `$HOME`. |
| `.gitconfig` | **Unmanaged** by `fresh.sh`. |
| `.gitignore_global` | **Unmanaged** by `fresh.sh`. |
| `.tmux.conf` | **Unmanaged** by `fresh.sh`. |
| `aliases.zsh` | **Unmanaged** by `fresh.sh`. Not explicitly sourced by current `.zshrc`. |
| `path.zsh` | **Unmanaged** by `fresh.sh`. Not explicitly sourced by current `.zshrc`. |
| `Brewfile` | Used by `fresh.sh` (via `brew bundle`) but not symlinked. |
| `.macos` | Executed as a script by `fresh.sh`, not symlinked. |

### 4. Zsh Configuration Details
- **External Files**: The `README.md` mentions that `aliases.zsh` and `path.zsh` are loaded because `$ZSH_CUSTOM` points to `.dotfiles`.
- **Implementation Reality**: The current `.zshrc` sets `export DOTFILES=$HOME/.dotfiles` but does **not** set `ZSH_CUSTOM` to this path. It assumes the default Oh My Zsh custom directory. Therefore, `aliases.zsh` and `path.zsh` in the dotfiles root are currently ineffective unless manually linked or moved to `~/.oh-my-zsh/custom`.

## Code References
- `fresh.sh:22`: `ln -sw $HOME/.dotfiles/.zshrc $HOME/.zshrc` - Explicit symlink creation for Zsh.
- `fresh.sh:38`: `ln -s ./.mackup.cfg $HOME/.mackup.cfg` - Explicit symlink creation for Mackup.
- `.zshrc:13`: `export DOTFILES=$HOME/.dotfiles` - Defines dotfiles location but does not integrate it into Zsh's autoloading path.
- `README.md:74`: Claims `aliases.zsh` gets loaded via `$ZSH_CUSTOM`, which conflicts with the code in `.zshrc`.

## Architecture Documentation
The system is built on a "run-once" setup script (`fresh.sh`) that bootstraps the environment (Xcode, Homebrew, OMZ). Configuration persistence is split between:
1.  **Git-managed core files**: `.zshrc` and `.mackup.cfg` (linked via script).
2.  **Cloud-synced app configs**: Managed by `mackup` (restored via iCloud).
3.  **Static files**: Several dotfiles exist in the repo but lack an automated deployment mechanism in the current codebase.

## Open Questions
- Are `aliases.zsh` and `path.zsh` intended to be symlinked to `$HOME` or integrated into `$ZSH_CUSTOM`?
- Should the "orphaned" files (`.gitconfig`, `.tmux.conf`) be managed similarly to `.zshrc`?

## Follow-up Research 2026-02-04

### Clarification on Configuration Files
Based on user input provided on 2026-02-04:
- **`aliases.zsh` & `path.zsh`**: These files are intended to be integrated directly into `.zshrc` (sourced) so that their rules are applied when the shell starts. They are not intended to be symlinked individually to `$HOME` or rely on `ZSH_CUSTOM`.
- **Unmanaged Dotfiles**: All currently unmanaged dotfiles (e.g., `.gitconfig`, `.tmux.conf`, etc.) are intended to be included in the configuration management system.
