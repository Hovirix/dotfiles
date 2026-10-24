## Context

The Git repository is the single source of truth. GNU Stow links individual files into `$HOME`.

## Rules
- Follow KISS and DRY. Write minimal, readable code.
- Edit canonical repository files whenever possible; live files are symlinked here.
- Never replace symlinks with regular files or use atomic replacement operations that break symlinks.
- Run Stow with `--no-folding` only when installing, removing, or restructuring packages.
- Never run the former dotfile manager's commands.
- Keep `.github`, `.opencode`, `assets`, `AGENTS.md`, and `README.md` out of deployment.
- Keep application-specific agent configuration in its existing application path.
- Preserve existing behavior unless explicitly requested otherwise.
- Keep `~/.gnupg` and `~/.ssh` real directories with mode 0700; managed configuration targets need mode 0600. Never track keys, credentials, or runtime data.
- Review changes with `git diff`. Run only tests relevant to modified configurations.
- Use Conventional Commits with the Stow package name as the scope (e.g. `fix(zsh): ...`); omit the scope for repository-wide changes.
- Never edit `README.md` unless explicitly asked.
