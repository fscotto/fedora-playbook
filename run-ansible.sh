#!/usr/bin/env bash
# =============================================================================
# Ansible Bootstrap Wrapper - Debian 13 Trixie Workstation
# =============================================================================
# Questo script installa Ansible e le sue dipendenze, poi esegue il playbook
# Uso: chmod +x run-ansible.sh && ./run-ansible.sh
# =============================================================================

set -euo pipefail

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}══════════════════════════════════════${NC}"; }

# Verifica che non venga eseguito come root
if [ "$EUID" -eq 0 ]; then
    error "Non eseguire questo script come root. Usa il tuo utente normale."
fi

# Verifica di essere su Debian
if [ ! -f /etc/debian_version ]; then
    error "Questo script è progettato per Debian. Sistema operativo non supportato."
fi

# =============================================================================
# INSTALLAZIONE ANSIBLE
# =============================================================================
section "Verifica e installazione Ansible"

if ! command -v ansible-playbook &> /dev/null; then
    log "Ansible non trovato, procedo con l'installazione..."
    
    sudo apt update
    sudo apt install -y ansible
    
    log "Ansible installato con successo"
else
    ANSIBLE_VERSION=$(ansible --version | head -n1)
    log "Ansible già installato: $ANSIBLE_VERSION"
fi

# =============================================================================
# INSTALLAZIONE COLLEZIONI ANSIBLE
# =============================================================================
# section "Installazione collezioni Ansible"

# if [ -f "requirements.yml" ]; then
#     ansible-galaxy collection install -r requirements.yml
#     log "Collezioni Ansible installate"
# else
#     warn "File requirements.yml non trovato, installo community.general manualmente"
#     ansible-galaxy collection install community.general
# fi

# =============================================================================
# VERIFICA PLAYBOOK
# =============================================================================
section "Verifica playbook"

if [ ! -f "playbook.yml" ]; then
    error "File playbook.yml non trovato nella directory corrente"
fi

log "Playbook trovato: playbook.yml"

# =============================================================================
# ESECUZIONE PLAYBOOK
# =============================================================================
section "Esecuzione playbook Ansible"

warn "Il playbook richiederà la password sudo per alcuni task."
warn "Premi CTRL+C per annullare, oppure INVIO per continuare..."
read -r

ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass

# =============================================================================
# RIEPILOGO FINALE
# =============================================================================
section "Esecuzione completata"

echo ""
echo -e "${GREEN}✔ Playbook Ansible eseguito con successo${NC}"
echo ""
echo -e "${YELLOW}Azioni manuali richieste dopo il riavvio:${NC}"
echo -e "${YELLOW}  1. Lanciare 'jetbrains-toolbox' per installare IntelliJ IDEA Ultimate${NC}"
echo -e "${YELLOW}  2. Abilitare PaperWM: gnome-extensions enable paperwm@paperwm.github.com${NC}"
echo -e "${YELLOW}  3. Configurare YubiKey PAM (inserisci YubiKey e lancia pamu2fcfg)${NC}"
echo -e "${YELLOW}  4. Verificare: java -version && mvn -version${NC}"
echo -e "${YELLOW}  5. Aggiornare AppImage: am -u (o am -U per aggiornare tutto)${NC}"
echo ""
warn "Riavvia il sistema per applicare tutte le modifiche."
