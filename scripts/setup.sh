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

# ---- 1. Vérifier Claude Code ----
echo -e "${BLUE}[1/4]${NC} Vérification de Claude Code..."

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

# ---- 3. Configuration MCP ----
echo -e "${BLUE}[3/4]${NC} Configuration MCP..."

echo -e "  ${GREEN}✓${NC} Serveur MCP pré-configuré : ${BOLD}findflights.me${NC} (Aviasales)"
echo -e "    Transport : SSE"
echo -e "    URL : https://findflights.me/sse"
echo -e "    Clé API : non requise"
echo ""

# ---- 4. Source supplémentaire (optionnel) ----
echo -e "${BLUE}[4/4]${NC} Sources supplémentaires (optionnel)..."
echo ""
echo -e "  Flight Sniper fonctionne avec findflights.me par défaut."
echo -e "  Pour de meilleurs résultats, vous pouvez ajouter une 2e source :"
echo ""
echo -e "  ${BOLD}Google Flights via SerpAPI :${NC}"
echo -e "    1. Obtenir une clé API sur https://serpapi.com"
echo -e "    2. Cloner : git clone https://github.com/arjunprabhulal/mcp-flight-search.git"
echo -e "    3. Ajouter le serveur dans .claude/settings.json"
echo -e "    Voir README.md pour les instructions détaillées."
echo ""

read -p "  Voulez-vous configurer SerpAPI maintenant ? (o/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Oo]$ ]]; then
    read -p "  Entrez votre clé SerpAPI : " SERPAPI_KEY
    if [ -n "$SERPAPI_KEY" ]; then
        echo -e "  ${YELLOW}Note :${NC} Ajoutez cette clé dans .claude/settings.json"
        echo -e "  sous mcpServers.google-flights.env.SERPAPI_KEY"
        echo -e "  Voir README.md section 'Ajouter une 2e source MCP'"
        echo ""
        echo -e "  ${GREEN}✓${NC} Clé notée. Suivez les instructions du README pour finaliser."
    fi
else
    echo -e "  ${GREEN}→${NC} Pas de problème, findflights.me suffit pour commencer."
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
echo -e "  ${YELLOW}→${NC} Vol le moins cher Paris-Bangkok en avril, flexible ±7 jours"
echo -e "  ${YELLOW}→${NC} Paris-Tokyo en mars, confort, budget 1200€ max"
echo -e "  ${YELLOW}→${NC} Compare les prix depuis CDG, ORY et BVA pour Londres"
echo ""
echo -e "  ${BOLD}Documentation :${NC} docs/guide.md"
echo ""
