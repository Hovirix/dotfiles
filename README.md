# HX dots

Mango, Quickshell, and a keyboard-driven Wayland desktop, managed with GNU Stow.

## Organization

Each top-level application directory is a Stow package mirroring paths under
`$HOME`: `helix/.config/helix/config.toml`, `zsh/.zshrc`, and so on.
`desktop` contains launchers and icons; `scripts` contains executables.
`wallpapers/Pictures/Wallpapers` provides `~/Pictures/Wallpapers`.

`.github`, `.opencode`, `assets`, `AGENTS.md`, and this README are not deployed.
`assets/.stow-local-ignore` excludes the remaining non-deployed assets.
Repository-specific skills stay in `.opencode`; global agent settings live in
`opencode/.config/opencode`.

## Install

Install GNU Stow with your package manager (on NixOS: `nix profile add nixpkgs#stow`).
Clone anywhere, then work from the actual repository root:

```sh
git clone https://github.com/Hovirix/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Required on every clone: Git does not retain these restrictive permissions.
mkdir -p "$HOME/.gnupg" "$HOME/.ssh"
chmod 700 "$HOME/.gnupg" "$HOME/.ssh" gpg/.gnupg ssh/.ssh
chmod 600 gpg/.gnupg/* ssh/.ssh/config

stow -n -v --no-folding -t "$HOME" */  # preview all packages
stow --no-folding -t "$HOME" */
```

The repository root is the package directory; there is no nested `packages/`.
`.stowrc` also defaults to `--no-folding`: directories remain real, and only
individual files are symlinked. Hidden repository directories are not in `*/`;
`assets` is a no-op package because of its ignore file.

Install or remove individual packages from the repository root:

```sh
stow -n -v --no-folding -t "$HOME" helix
stow --no-folding -t "$HOME" helix
stow -D --no-folding -t "$HOME" helix
```

Removal unlinks managed files, not their repository sources or unrelated files.

## Edit and add files

Edit the repository file or its live symlink, then review `git diff` and commit.
There is no synchronization step; applications retain their usual reload rules.
Configure editors to write through symlinks, not replace them using atomic saves.

Add files under the appropriate package using their normal home-relative paths,
preserve executable modes with `chmod +x`, then preview and rerun Stow for that
package. Run Stow only for installation, removal, or structural changes.

Upgrade Yazi plugins explicitly with `upgrade-yazi-plugins`; review any resulting
changes to `yazi/.config/yazi/package.toml`. Existing untracked plugins stay local.

## Existing-file conflicts and sensitive files

Never force conflicts or blindly adopt files. Compare existing files with the
repository, preserve intentional changes, and back up conflicting files outside
the repository before moving them out of the target paths. Preview Stow again.
For an existing directory symlink, inspect and back up its contents before
replacing it with a real directory; do not overwrite unmanaged data.

`~/.gnupg` and `~/.ssh` must **remain real directories**, mode 0700. Only the
tracked configuration files are linked; their repository targets need mode 0600
as shown above. Keep these permissions when adding configuration files.
Private keys, keyrings, trust databases, known hosts, tokens, and runtime state
remain local and must never be added to Git. Stow does not configure or reset
hardware security keys. Keep backups containing sensitive data private.
