# Adopt GNU Stow for Dotfiles Management

## Overview
This plan transitions the dotfiles repository to use **GNU Stow** for managing symlinks. We will maintain the current "flat" directory structure (no package subdirectories) and use a `.stow-local-ignore` file to prevent Stow from symlinking repository metadata (like README, scripts, etc.) to the home directory.

## Current State Analysis
*   **Symlinking**: handled by `fresh.sh` via explicit `ln -s` commands.
*   **Coverage**: Only `.zshrc` and `.mackup.cfg` are currently linked.
*   **Unmanaged**: `.gitconfig`, `.gitignore_global`, `.tmux.conf`, `.p10k.zsh` are in the repo but not symlinked.
*   **Zsh Extras**: `aliases.zsh` and `path.zsh` exist but are not sourced by `.zshrc`.
*   **Tooling**: `stow` is not currently installed.

## Desired End State
*   **Tooling**: GNU Stow manages all symlinks using the root directory as the package.
*   **Structure**: Files remain in the root of `.dotfiles`.
*   **Cleanliness**: Repository metadata (`README.md`, `fresh.sh`, etc.) is ignored by Stow.
*   **Automation**: `fresh.sh` installs `stow` and runs `stow .` to idempotentally set up links.
*   **Completeness**: All configuration files (`.zshrc`, `.gitconfig`, `.tmux.conf`, etc.) are symlinked to `$HOME`.
*   **Integration**: `aliases.zsh` and `path.zsh` are renamed to `.aliases.zsh` and `.path.zsh` (hidden) and sourced by `.zshrc`.

### Key Discoveries:
*   `fresh.sh` manually removes `~/.zshrc` before linking.
*   `.zshrc` does not currently source `aliases.zsh` or `path.zsh`.
*   `ssh.sh` modifies `~/.ssh/config` in place; this will remain outside Stow for safety.

## What We're NOT Doing
*   Moving files into semantic subdirectories (e.g., `git/`, `zsh/`).
*   Managing `~/.ssh/config` via Stow.

## Implementation Approach
1.  **Cleanup**: Create `.stow-local-ignore` to exclude non-config files.
2.  **Rename**: `aliases.zsh` -> `.aliases.zsh`, `path.zsh` -> `.path.zsh`.
3.  **Update**: Modify `.zshrc` to source the new hidden files.
4.  **Automate**: Update `Brewfile` and `fresh.sh` to drive the process.

---

## Phase 1: Preparation and Rename

### Overview
Rename files to be hidden (cleaner home dir) and configure Stow exclusions.

### Changes Required:

#### 1. Create .stow-local-ignore
**File**: `.stow-local-ignore`
**Content**:
```text
\.git
\.github
\.DS_Store
.*\.md
.*\.sh
Brewfile
plans
research
\.stow-local-ignore
```
*Note: This ensures `fresh.sh`, `README.md`, etc., are not linked to `$HOME`.*

#### 2. Rename Files
**Action**:
*   `aliases.zsh` -> `.aliases.zsh`
*   `path.zsh` -> `.path.zsh`

#### 3. Update Brewfile
**File**: `Brewfile`
**Changes**: Add `brew "stow"`.

### Success Criteria:
#### Automated Verification:
*   [x] `brew bundle check` confirms `stow` is listed.
*   [x] Files renamed successfully.
*   [x] `.stow-local-ignore` exists.

---

## Phase 2: Configuration Logic Updates

### Overview
Update `.zshrc` to source the renamed files.

### Changes Required:

#### 1. Update .zshrc
**File**: `.zshrc`
**Changes**: Add sourcing for the new hidden alias and path files.
```zsh
# Load custom aliases and path configurations
[[ -f "$HOME/.aliases.zsh" ]] && source "$HOME/.aliases.zsh"
[[ -f "$HOME/.path.zsh" ]] && source "$HOME/.path.zsh"
```

### Success Criteria:
#### Manual Verification:
*   [x] Verify `.zshrc` contains the new source lines.

---

## Phase 3: Automation with Fresh.sh

### Overview
Update the installation script to use Stow.

### Changes Required:

#### 1. Update fresh.sh
**File**: `fresh.sh`
**Changes**:
*   Remove manual `rm` and `ln` commands for `.zshrc` and `.mackup.cfg`.
*   Add command to run stow.
*   Ensure `stow` is installed.

```bash
# ... after brew bundle ...

# Use Stow to symlink dotfiles
# -v: verbose
# --adopt: treat existing files in target as if they belong to stow (useful for first run if user has files)
# . : stow the current directory
echo "Stowing dotfiles..."
stow -v --adopt .
```

*Note: `fresh.sh` previously did `rm -rf ~/.zshrc`. Stow with `--adopt` will effectively take over existing files in `$HOME`. If they differ, it updates the repo version. If we want the repo version to be authoritative, we might want `stow -R .` (Restow). Given the user wants to "adopt" Stow, `--adopt` is safer for existing files, OR we stick to `fresh.sh`'s "overwrite" policy by removing conflicts first? Actually, `stow` creates links. If link exists, it skips. If file exists, it conflicts. `fresh.sh` used to delete `.zshrc`. We should probably `rm` the files we *know* we want to replace to avoid Stow conflicts, or just rely on `stow --adopt` (which modifies the REPO file to match HOME file if conflict) followed by `git restore .` if we want to enforce repo state. A simpler path for `fresh.sh` is `stow --restow .` which effectively fixes links.*
*Decision: We will use `stow .` and let it warn/fail on conflicts, but since `fresh.sh` is a setup script, we can keep the `rm` for the critical ones we know we are replacing (`.zshrc`) to ensure the link happens cleanly, OR better, let Stow handle it. We will try `stow --restow .`.*

### Success Criteria:
#### Automated Verification:
*   [x] `fresh.sh` runs without errors.
*   [x] `ls -l ~/.zshrc` shows symlink to `.dotfiles/.zshrc`.
*   [x] `ls -l ~/.gitconfig` shows symlink to `.dotfiles/.gitconfig`.

#### Manual Verification:
*   [x] Shell starts correctly.
*   [x] Aliases available.

---

## Testing Strategy

### Manual Testing Steps:
1.  Run `fresh.sh`.
2.  Verify symlinks in `$HOME`.
3.  Restart shell.
4.  Check aliases.
