# Debian 13 Trixie Workstation - Ansible Setup

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
sudo apt update
sudo apt install ansible

# 2. Installa le collezioni necessarie
ansible-galaxy collection install -r requirements.yml

# 3. Esegui il playbook
ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass
```

Il flag `--ask-become-pass` chiederà la password sudo all'inizio.

## Idempotenza

Il playbook può essere eseguito più volte senza problemi. Ansible salta i task già completati.

## Azioni manuali post-esecuzione

Dopo il riavvio:

1. Lanciare `jetbrains-toolbox` per installare IntelliJ IDEA Ultimate
2. Abilitare PaperWM: `gnome-extensions enable paperwm@paperwm.github.com`
3. Configurare YubiKey PAM (vedi istruzioni nello script bash)
4. Verificare: `java -version && mvn -version`
5. Aggiornare AppImage quando necessario: `am -u` (singola app) o `am -U` (tutte)

## Gestione AppImage con AM

Il playbook installa **AM (AppImage Manager)** per gestire:
- Telegram
- Spotify
- Postman
- DevPod

Comandi utili AM:
- `am -l` - lista app installate
- `am -u <app>` - aggiorna singola app
- `am -U` - aggiorna tutte le app
- `am -r <app>` - rimuove app
- `am -q <termine>` - cerca app disponibili

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

- I task Mise e Stow usano `shell` perché non esistono moduli Ansible nativi
- AM (AppImage Manager) gestisce Telegram, Spotify, Postman, DevPod
- Nerd Fonts installati: 0xProto, ComicShannsMono, FiraCode, JetBrainsMono, UbuntuMono, UbuntuSans, Iosevka
- Il playbook assume esecuzione locale (`localhost`)
