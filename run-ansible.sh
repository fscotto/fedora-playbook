#!/usr/bin/env bash
# =============================================================================
# Ansible Bootstrap Wrapper - Fedora XFCE 43 Workstation
# =============================================================================
# Questo script installa Ansible e le sue dipendenze, poi esegue il playbook
# Uso: chmod +x run-ansible.sh && ./run-ansible.sh
# =============================================================================

set -Eeuo pipefail

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
RUN_TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/ansible-run-${RUN_TS}.log"

mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

log()     { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}══════════════════════════════════════${NC}"; }

on_error() {
    local exit_code=$?
    local line_no=${1:-unknown}
    echo ""
    echo -e "${RED}[✘]${NC} Esecuzione interrotta (linea ${line_no}, exit code ${exit_code})."
    echo -e "${YELLOW}[!]${NC} Controlla le righe precedenti per il task che ha fallito (spesso in fase Btrfs/Snapper)."
    echo -e "${YELLOW}[!]${NC} Per debug dettagliato: ansible-playbook -i localhost, -c local playbook.yml --ask-become-pass -vv"
    if [ -t 0 ]; then
        echo ""
        warn "Premi INVIO per chiudere..."
        read -r || true
    fi
    exit "$exit_code"
}

trap 'on_error $LINENO' ERR

log "Log esecuzione: ${LOG_FILE}"

# Verifica che non venga eseguito come root
if [ "$EUID" -eq 0 ]; then
    error "Non eseguire questo script come root. Usa il tuo utente normale."
fi

# Verifica di essere su Fedora
if [ ! -f /etc/fedora-release ]; then
    error "Questo script è progettato per Fedora XFCE. Sistema operativo non supportato."
fi

# =============================================================================
# INSTALLAZIONE ANSIBLE
# =============================================================================
section "Verifica e installazione Ansible"

if ! command -v ansible-playbook &> /dev/null; then
    log "Ansible non trovato, procedo con l'installazione..."

    sudo dnf install -y ansible

    log "Ansible installato con successo"
else
    ANSIBLE_VERSION=$(ansible --version | head -n1)
    log "Ansible già installato: $ANSIBLE_VERSION"
fi

# =============================================================================
# INSTALLAZIONE COLLEZIONI ANSIBLE (opzionale)
# =============================================================================
section "Installazione collezioni Ansible"

if [ -f "requirements.yml" ]; then
    if awk '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*---[[:space:]]*$/ { next }
        /^[[:space:]]*collections:[[:space:]]*$/ { next }
        { found=1; exit }
        END { exit !found }
    ' requirements.yml; then
        ansible-galaxy collection install -r requirements.yml
        log "Collezioni Ansible installate"
    else
        warn "requirements.yml presente ma senza collezioni: salto installazione"
    fi
else
    warn "File requirements.yml non trovato, continuo senza collezioni aggiuntive"
fi

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
echo -e "${YELLOW}  2. Verificare login/sudo con YubiKey (fallback password attivo)${NC}"
echo -e "${YELLOW}  3. Verificare unlock LUKS2 con YubiKey al boot (quando abilitato)${NC}"
echo -e "${YELLOW}  4. Verificare: java -version && mvn -version${NC}"
echo -e "${YELLOW}  5. Aggiornare Flatpak: flatpak update${NC}"
echo ""
warn "Riavvia il sistema per applicare tutte le modifiche."
