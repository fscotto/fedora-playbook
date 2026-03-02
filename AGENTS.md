# AGENTS.md - Fedora XFCE 43 Ansible Playbook

## Purpose
This file guides coding agents working in this repository.
The project is a Fedora-only local Ansible playbook for workstation bootstrap.
Primary goals are reproducibility, idempotency, and safe reruns.

## Repository Snapshot
- `playbook.yml`: entrypoint playbook and shared vars
- `tasks/10_storage.yml`: storage orchestration (preflight, Btrfs, Snapper/GRUB)
- `tasks/20_security.yml`: security orchestration (hardening, auth policy, updates, local audit)
- `tasks/30_system.yml`: package orchestration
- `tasks/40_apps.yml`: desktop applications orchestration
- `tasks/50_dev_tooling.yml`: developer tooling orchestration
- `tasks/60_identity.yml`: YubiKey/LUKS2/PAM orchestration
- `tasks/70_user_env.yml`: user environment orchestration
- `run-ansible.sh`: bootstrap wrapper around Ansible execution
- `requirements.yml`: Ansible Galaxy collections input (currently minimal)

## Build / Lint / Test Commands

### Full run (preferred)
```bash
chmod +x run-ansible.sh
./run-ansible.sh
```

### Full run (manual)
```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

### Syntax and structure checks
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

### Shell validation
```bash
bash -n run-ansible.sh
shellcheck run-ansible.sh
```

### Safe validation sequence
There are no unit tests in this repo.
Use this sequence when changing playbook logic:
```bash
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass --check --diff
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

### Single-test equivalent (focused verification)
This playbook has no tags yet, so use `--start-at-task` or `--step`.
```bash
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass \
  --start-at-task "Install YubiKey and smartcard packages"

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass \
  --start-at-task "Configure Snapper and GRUB integration for Btrfs" --check --diff

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass --step
```

Recommended future improvement: add tags for each imported task file.

## Code Style Guidelines

### YAML and formatting
- Use 2-space indentation; do not use tabs.
- Keep lines near 120 chars when practical.
- Remove trailing whitespace.
- Use blank lines between logical blocks.
- Prefer double quotes for templated strings and paths.
- Use explicit booleans (`true` / `false`).

### Module usage and task imports
- Prefer Ansible modules over `shell`/`command`.
- Use `import_tasks` for static task graph composition (current project style).
- Prefer these modules where applicable: `dnf`, `file`, `copy`, `lineinfile`, `git`, `mount`, `sysctl`, `systemd`, `stat`, `uri`, `get_url`, `unarchive`.
- Use `command` only for tools without strong module coverage (`findmnt`, `rsync`, `stow`, etc.).
- Use `shell` only when shell features are required (pipes, multiline scripts, env activation).

### Variables, data types, templating
- Keep reusable values in play-level `vars`.
- Use descriptive `snake_case` variable names.
- Keep package/app collections as YAML lists, not comma-separated strings.
- Use `{{ ... }}` templating consistently.
- Prefer variables over hardcoded literals when values may change.

### Naming conventions
- Task names should be action-first and explicit.
- Start names with verbs like `Install`, `Configure`, `Enable`, `Create`, `Check`, `Verify`.
- Include target context in task names (`... for Btrfs`, `... via Flatpak`, etc.).
- Handler names should describe effect (`Regenerate grub config`, `Reload udev rules`).

### Idempotency and change reporting
- Every task must be safe to rerun.
- Guard one-time operations with `creates`, `stat` + `when`, or equivalent checks.
- Set `changed_when: false` for probe/read-only commands.
- Use `failed_when: false` only when non-zero return is expected and handled.
- Use handlers for restart/reload actions triggered by real changes.

### Error handling and assertions
- Fail fast on real precondition violations.
- Use `assert` for environment assumptions (Fedora-only behavior).
- Use `ignore_errors: true` only for clearly optional tasks.
- If ignoring errors, keep following logic resilient and explicit.

### Privilege escalation and security
- Keep play-level `become: false` (current project convention).
- Set `become: true` only on tasks that need elevated privileges.
- Avoid writing secrets to logs or tracked files.
- Prefer secure defaults for permissions (`0644` files, `0755` dirs unless stricter is required).

### Shell script conventions (`run-ansible.sh`)
- Keep `set -euo pipefail`.
- Quote variable expansions unless splitting is intentional.
- Keep clear preflight checks (non-root, Fedora detection, required files).
- Print actionable failure messages.
- Avoid destructive operations without explicit opt-in.

## Domain-Specific Expectations
- Target OS is Fedora XFCE (not GNOME customization-focused).
- Btrfs behavior is conditional on root filesystem detection.
- RPM Fusion is part of package bootstrap.
- Flatpak app management is through Flathub IDs in `flatpak_apps`.
- Java and Maven are managed via Mise, not system-default packages.

## Agent Workflow Expectations
- Before edits: read relevant task files and shared vars in `playbook.yml`.
- After edits: run syntax check first, then lint, then focused check-mode run.
- For risky filesystem logic (Btrfs migration), prefer `--check --diff` plus targeted start task.
- Keep changes scoped; avoid unrelated refactors in the same patch.
- Preserve existing language style when touching user-facing messages.

## Assistant Rule Files (Cursor/Copilot)
Checked paths in this repository:
- `.cursor/rules/` -> not present
- `.cursorrules` -> not present
- `.github/copilot-instructions.md` -> not present

If any of these files are added later, treat them as higher-priority guidance than this AGENTS.md.

## Commit Guidance
- Use conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).
- Keep commits focused by concern (playbook logic vs docs vs wrapper script).
- Before committing, run at least:
  - `git status`
  - `git diff`
  - `ansible-playbook playbook.yml --syntax-check`
  - `ansible-lint playbook.yml` and/or `yamllint .`
