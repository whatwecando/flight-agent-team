#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Flight Sniper — Script d'installation
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║        Flight Sniper — Setup             ║${NC}"
echo -e "${BOLD}║   Trouvez le vrai meilleur prix          ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ---- 1. Vérifier les prérequis ----
echo -e "${BLUE}[1/4]${NC} Vérification des prérequis..."

# Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "inconnue")
    echo -e "  ${GREEN}✓${NC} Node.js installé (${NODE_VERSION})"
else
    echo -e "  ${RED}✗${NC} Node.js n'est pas installé."
    echo -e "  Installez Node.js 18+ : https://nodejs.org"
    exit 1
fi

# npx
if command -v npx &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} npx disponible"
else
    echo -e "  ${RED}✗${NC} npx non trouvé. Installez npm/npx."
    exit 1
fi

# Claude Code
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "version inconnue")
    echo -e "  ${GREEN}✓${NC} Claude Code installé (${CLAUDE_VERSION})"
else
    echo -e "  ${RED}✗${NC} Claude Code n'est pas installé."
    echo ""
    echo -e "  Pour installer Claude Code :"
    echo -e "  ${BOLD}npm install -g @anthropic-ai/claude-code${NC}"
    echo ""
    echo -e "  Documentation : https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# ---- 2. Vérifier la structure du projet ----
echo -e "${BLUE}[2/4]${NC} Vérification des fichiers du projet..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

REQUIRED_FILES=(
    "CLAUDE.md"
    ".claude/settings.json"
    ".claude/agents/flight-sniper.md"
    "data/airline-fees.md"
    "data/airport-alternatives.md"
    "data/memory/MEMORY.md"
    "data/memory/user-preferences.md"
    "data/memory/search-history.md"
    "README.md"
    "docs/guide.md"
)

ALL_OK=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file — MANQUANT"
        ALL_OK=false
    fi
done

if [ "$ALL_OK" = false ]; then
    echo ""
    echo -e "  ${RED}Certains fichiers sont manquants.${NC} Vérifiez votre installation."
    exit 1
fi

# ---- 3. Vérifier le serveur MCP ----
echo -e "${BLUE}[3/4]${NC} Vérification du serveur MCP Google Flights..."

echo -e "  Serveur MCP configuré : ${BOLD}google-flights-mcp-server${NC}"
echo -e "  Transport : stdio (local via npx)"
echo -e "  Clé API : ${GREEN}non requise${NC}"
echo ""
echo -e "  Outils disponibles :"
echo -e "    ${YELLOW}→${NC} search_flights — Recherche de vols avec filtres"
echo -e "    ${YELLOW}→${NC} get_date_grid — Grille de prix sur ~60 jours"
echo -e "    ${YELLOW}→${NC} find_airport_code — Résolution codes IATA"
echo ""

echo -n "  Test de google-flights-mcp-server... "
if npx -y google-flights-mcp-server --help &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}non vérifiable en mode CLI${NC} (normal, le serveur démarre en mode MCP)"
fi

# ---- 4. Mémoire persistante ----
echo -e "${BLUE}[4/4]${NC} Mémoire persistante..."

if [ -f "$PROJECT_DIR/data/memory/user-preferences.md" ] && [ -f "$PROJECT_DIR/data/memory/search-history.md" ]; then
    echo -e "  ${GREEN}✓${NC} Système de mémoire initialisé"
    echo -e "    Préférences : data/memory/user-preferences.md"
    echo -e "    Historique : data/memory/search-history.md"
else
    echo -e "  ${YELLOW}!${NC} Fichiers mémoire manquants — ils seront créés à la première recherche"
fi

# ---- Résumé ----
echo ""
echo -e "${BOLD}══════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Installation terminée !${NC}"
echo -e "${BOLD}══════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Pour commencer :${NC}"
echo -e "  ${BLUE}cd $(basename "$PROJECT_DIR") && claude${NC}"
echo ""
echo -e "  ${BOLD}Exemples de requêtes :${NC}"
echo ""
echo -e "  ${YELLOW}→${NC} Trouve-moi un vol Paris-New York du 15 au 22 mars"
echo -e "  ${YELLOW}→${NC} Quand est-ce le moins cher pour aller à Tokyo depuis Paris ?"
echo -e "  ${YELLOW}→${NC} Vol le moins cher Paris-Bangkok en avril, flexible ±7 jours"
echo -e "  ${YELLOW}→${NC} Compare les prix depuis CDG, ORY et BVA pour Londres"
echo ""
echo -e "  ${BOLD}Documentation :${NC} docs/guide.md"
echo ""
