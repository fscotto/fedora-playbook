# Fedora XFCE 43 Workstation - Ansible Setup

## Uso rapido (consigliato)

```bash
# Rendi eseguibile lo script wrapper
chmod +x run-ansible.sh

# Esegui - installerà Ansible e lancerà il playbook
./run-ansible.sh
```

Lo script wrapper `run-ansible.sh` si occupa di:
1. Verificare/installare Ansible
2. Installare le collezioni necessarie
3. Eseguire il playbook

## Uso manuale (avanzato)

Se preferisci controllare ogni passaggio:

```bash
# 1. Installa Ansible
sudo dnf install ansible

# 2. Installa le collezioni necessarie
ansible-galaxy collection install -r requirements.yml

# 3. Esegui il playbook
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

Il flag `--ask-become-pass` chiederà la password sudo all'inizio.

Nota: il playbook e` modulare e importa task da `tasks/*.yml` per area funzionale.

## Idempotenza

Il playbook può essere eseguito più volte senza problemi. Ansible salta i task già completati.

## Azioni manuali post-esecuzione

Dopo il riavvio:

1. Lanciare `jetbrains-toolbox` per installare IntelliJ IDEA Ultimate
2. Verificare login/sudo con YubiKey (fallback password attivo)
3. Verificare unlock LUKS2 con YubiKey al boot (quando abilitato)
4. Verificare: `java -version && mvn -version`
5. Aggiornare Flatpak quando necessario: `flatpak update`

## Btrfs + Snapper + GRUB

Se il filesystem root e` Btrfs, il playbook:
- crea i subvolume aggiuntivi (`@log`, `@cache`, `@snapshots`, `@libvirt`)
- monta `@cache` su `/var/cache` e `@log` su `/var/log`
- monta `@libvirt` su `/var/lib/libvirt`
- monta `@snapshots` su `/.snapshots`
- configura Snapper (`root`) con policy timeline/cleanup
- abilita i timer `snapper-timeline.timer` e `snapper-cleanup.timer`
- tenta integrazione GRUB snapshot menu con `grub-btrfs` quando disponibile

Comandi utili:
- `sudo snapper -c root list`
- `sudo snapper -c root create --description "manual pre-change"`
- `systemctl status snapper-timeline.timer snapper-cleanup.timer`
- `systemctl status grub-btrfs.path`

## Gestione applicazioni con Flatpak

Il playbook installa e configura **Flatpak** (Flathub) per gestire:
- Google Chrome
- Telegram
- Spotify
- Postman
- DevPod

Comandi utili Flatpak:
- `flatpak list` - lista app installate
- `flatpak update` - aggiorna tutte le app Flatpak
- `flatpak update <app-id>` - aggiorna singola app
- `flatpak uninstall <app-id>` - rimuove app
- `flatpak search <termine>` - cerca app disponibili

## Confronto con lo script Bash

**Vantaggi Ansible:**
- Idempotenza garantita (rieseguibile senza effetti collaterali)
- Struttura più dichiarativa
- Handlers per azioni condizionali (es. reload udev solo se cambiato)
- Facile da estendere con ruoli separati
- Migliore per gestire più macchine

**Svantaggi Ansible:**
- Più verboso (500+ righe vs 300 bash)
- Richiede installazione Ansible
- Curva di apprendimento YAML/Ansible
- Overhead per singola workstation

## Note

- I task Mise usano `shell` perché non esistono moduli Ansible nativi equivalenti
- I task Stow usano `command`
- Flatpak (Flathub) gestisce Google Chrome, Telegram, Spotify, Postman, DevPod
- Font installati: Liberation (Mono/Sans/Serif) + Nerd Fonts 0xProto, ComicShannsMono, FiraCode, JetBrainsMono, UbuntuMono, UbuntuSans, Iosevka
- Il playbook assume esecuzione locale (`localhost`)
- Il playbook e il wrapper sono Fedora-only (target: Fedora XFCE Spin)
