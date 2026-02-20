# AGENTS.md - Debian Ansible Playbook

## Project Overview

This is an Ansible playbook for setting up a Debian 13 Trixie workstation. It automates the installation of development tools, utilities, and system configurations.

## Commands

### Run the Playbook

```bash
# Using the wrapper script (recommended)
chmod +x run-ansible.sh
./run-ansible.sh

# Manual execution
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

### Syntax Check

```bash
# Check playbook syntax
ansible-playbook playbook.yml --syntax-check

# List all tasks without executing
ansible-playbook playbook.yml --list-tasks
```

### Linting

```bash
# Install ansible-lint first
pip install ansible-lint

# Lint the playbook
ansible-lint playbook.yml

# Install yamllint for YAML validation
pip install yamllint

# Lint YAML files
yamllint .
yamllint playbook.yml
```

### Dry Run (Check Mode)

```bash
# Run in check mode (no changes made)
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass --check
```

---

## Code Style Guidelines

### YAML Formatting

- **Indentation**: Use 2 spaces for indentation (no tabs)
- **Line length**: Keep lines under 120 characters when practical
- **Trailing spaces**: Never include trailing whitespace
- **Blank lines**: Use blank lines to separate logical sections
- **Quotes**: Use quotes for strings containing special characters or colons

### Ansible Best Practices

#### Task Naming
- Use descriptive names for all tasks
- Start with verb: "Install X", "Configure Y", "Enable Z"
- Include context: "Enable contrib, non-free and non-free-firmware repositories"

#### Idempotency
- Always use appropriate Ansible modules (apt, file, lineinfile, etc.)
- Use `creates` or `when` conditions to skip already-completed tasks
- Use `changed_when` when shell/command tasks don't actually change state
- Use `ignore_errors` sparingly and only when failure is acceptable

#### Module Usage
- Prefer built-in modules over shell/command when possible:
  - Use `apt` instead of `shell: apt install`
  - Use `file` instead of `shell: mkdir -p`
  - Use `copy` instead of `shell: cp`
  - Use `lineinfile` for single line modifications
  - Use `template` for configuration files

#### Variables
- Define variables in the `vars` section at the play level
- Use descriptive variable names: `user_home`, `dotfiles_repo`, `java_version`
- Always reference variables with `{{ }}` syntax
- Use `ansible_env.HOME` for user home directory

#### Become/Privilege Escalation
- Set `become: false` at play level
- Use `become: true` only on specific tasks that need root
- Always use `--ask-become-pass` or `-K` when running

#### Handlers
- Use handlers for actions that should run only on changes (e.g., reload services)
- Name handlers descriptively: "Reload udev rules", "Restart nginx"

#### Error Handling
- Use `ignore_errors: yes` only for truly optional operations
- Register command results and check `rc` when needed
- Use `failed_when` and `changed_when` for fine-grained control

### File Organization

- Main playbook: `playbook.yml`
- Requirements: `requirements.yml` (ansible-galaxy collections)
- Wrapper script: `run-ansible.sh`

### Git Commits

- Use conventional commit format
- Example: `feat: add Java via Mise installation`
- Run `git status` and `git diff` before committing

---

## Testing Strategy

Since this is a configuration management playbook:

1. **Syntax check**: Always run `--syntax-check` before execution
2. **Check mode**: Use `--check` to preview changes
3. **Idempotency**: The playbook is designed to be re-run safely
4. **Manual testing**: Some tasks require post-reboot configuration (see README.md)

---

## Notes for Agents

- The playbook assumes local execution (`localhost`)
- Some tasks require YubiKey hardware to be present
- JetBrains Toolbox requires manual IDE installation after first run
- PaperWM GNOME extension must be enabled manually: `gnome-extensions enable paperwm@paperwm.github.com`
- Java and Maven are installed via Mise (not APT)
- AppImage apps (Telegram, Spotify, Postman, DevPod) are managed via AM
