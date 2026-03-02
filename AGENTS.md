# AGENTS.md - Fedora XFCE 43 Ansible Playbook

## Project Overview
This repository contains a local Ansible playbook that configures a Fedora XFCE 43 workstation.
It installs developer tooling, security packages (including YubiKey support), desktop apps via Flatpak,
and user-level setup (Mise, dotfiles, JetBrains Toolbox).

The playbook is Fedora-only by design.

## Repository Layout
- `playbook.yml`: main local playbook orchestrating modular task imports
- `tasks/`: modular task files grouped by domain (preflight, btrfs, hardening, packages, flatpak, tooling, yubikey, dotfiles)
- `run-ansible.sh`: wrapper that bootstraps Ansible and runs the playbook
- `requirements.yml`: optional Ansible Galaxy dependencies
- `README.md`: usage and post-run manual tasks

## Build / Lint / Test Commands

### Full execution
```bash
chmod +x run-ansible.sh
./run-ansible.sh

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

### Syntax and introspection
```bash
ansible-playbook playbook.yml --syntax-check
ansible-playbook playbook.yml --list-tasks
ansible-playbook playbook.yml --list-hosts
```

### Linting
```bash
python3 -m pip install --user ansible-lint yamllint
ansible-lint playbook.yml
yamllint .
yamllint playbook.yml
```

### Shell script checks
```bash
bash -n run-ansible.sh
shellcheck run-ansible.sh
```

### Validation strategy
There are no unit tests. Validate with syntax + lint + check mode + targeted task run.

```bash
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass --check --diff

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

### Single-test equivalent (single task)
Use one of these patterns when you need focused verification.

```bash
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass \
  --start-at-task "Install YubiKey packages"

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass \
  --start-at-task "Install YubiKey packages" --check --diff

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass --step
```

Note: the playbook currently does not define `tags`; if focused runs become common,
prefer adding explicit tags to major task groups.

## Code Style Guidelines

### YAML formatting
- Use 2-space indentation; never tabs.
- Keep lines near or under 120 chars when practical.
- Do not leave trailing whitespace.
- Use blank lines between logical task blocks.
- Prefer double quotes for templated strings and paths.
- Use `true` / `false` for booleans.

### Modules and imports (Ansible equivalent)
- Prefer Ansible modules over `shell`/`command`.
- Use `dnf` for package management.
- Use `rpm_key` + `yum_repository` for external repositories.
- Prefer `file`, `copy`, `lineinfile`, `git`, `systemd`, `stat`, `uri`, `get_url`, `unarchive`.
- Use `command` only when no higher-level module exists.
- Use `shell` only for shell-specific behavior (pipes, env activation, multi-line scripts).

### Types, templates, and variables
- Store reusable values in play-level `vars`.
- Use descriptive snake_case names (`user_home`, `flatpak_apps`, `stow_packages`).
- Reference variables with `{{ ... }}` consistently.
- Keep list data as YAML lists, not comma-separated strings.
- Avoid hardcoded literals in task bodies when a variable improves clarity.

### Naming conventions
- Give every task a clear action-first name.
- Start task names with verbs: `Install`, `Configure`, `Enable`, `Create`, `Clone`, `Verify`.
- Include context in the task name for readability.
- Name handlers by effect (`Reload udev rules`).

### Idempotency and change reporting
- Ensure playbook reruns are safe and predictable.
- Use `creates`, `stat` + `when`, or guard conditions for one-time actions.
- Set `changed_when: false` for probe/read-only commands.
- Use handlers for operations that should happen only after changes.
- Avoid tasks that always report changed unless explicitly intended.

### Error handling
- Fail fast on real errors.
- Use `ignore_errors: true` only for explicitly optional operations.
- Use `failed_when` when return-code semantics need customization.
- Use `assert` to enforce preconditions (for example, Fedora-only checks).

### Privilege escalation
- Keep play-level `become: false`.
- Add `become: true` only on tasks that require root.
- Use `--ask-become-pass` for manual runs.

### Shell script conventions (`run-ansible.sh`)
- Keep `set -euo pipefail`.
- Quote variable expansions unless splitting is intentional.
- Use explicit preflight checks and clear error messages.
- Keep script behavior idempotent where possible.
- Avoid destructive commands without explicit user intent.

## Fedora XFCE Notes
- Desktop baseline is Fedora XFCE Spin.
- GNOME-only customizations are out of scope.
- RPM Fusion is enabled by the playbook.
- Java and Maven are managed by Mise, not system defaults.
- Flatpak (Flathub) manages desktop apps (`com.google.Chrome`, `org.telegram.desktop`, `com.spotify.Client`, `com.getpostman.Postman`, `sh.loft.devpod`).

## Editor/Assistant Rule Files
No repository-specific rule files were found during analysis:
- `.cursor/rules/` not present
- `.cursorrules` not present
- `.github/copilot-instructions.md` not present

If these files are added later, agents must treat them as higher-priority guidance.

## Commit Guidance
- Use conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).
- Keep commit scope focused (playbook logic vs docs vs wrapper script).
- Before commit, run `git status`, `git diff`, syntax checks, and lint commands.
