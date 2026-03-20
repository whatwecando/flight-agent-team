# Flight Sniper

**Trouvez le vrai meilleur prix, pas le prix d'appel.**

Flight Sniper est un système de recherche de vols basé sur Claude Code qui utilise une architecture **Scan & Snipe** : il scanne d'abord la grille de prix sur ~60 jours pour identifier les dates optimales, puis lance des recherches parallèles ciblées et calcule le **Coût Total Réel** (prix + bagages + frais cachés + transport aéroport).

```
 "Paris → Tokyo, 15-22 mars"
          │
     CLAUDE.md (orchestrateur)
          │
          ├── 1. Comprendre les critères
          │
          ├── 2. Scanner — grille de prix ~60 jours
          │      "le mardi 12 mars est 170€ moins cher"
          │
          ├── 3. Snipe parallèle
          │      ├──► Sniper #1 : dates exactes
          │      ├──► Sniper #2 : dates optimales du scan
          │      └──► Sniper #3 : aéroport alternatif
          │             (en parallèle)
          │
          ├── 4. Analyser — Coût Total Réel
          │      prix + bagages + siège + transport + frais
          │
          └── 5. Recommander — TOP 5 + pièges détectés
```

## Ce qui rend Flight Sniper différent

| Approche classique | Flight Sniper |
|-------------------|---------------|
| 1 recherche, 1 résultat | Scan de prix sur 60 jours + recherches parallèles |
| Prix affiché = prix final | **Coût Total Réel** = prix + tous les frais cachés |
| Pas de contexte compagnies | Base de connaissances des frais par compagnie |
| Aéroport unique | Aéroports alternatifs avec coût de transport |
| Pas de mémoire | **Préférences et historique persistants** entre sessions |
| Suggestions de sites externes | **Recherche directe via MCP** — jamais de redirection |

---

## Prérequis

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installé
- Abonnement Claude (Pro ou Team)
- Node.js 18+

## Installation

```bash
# 1. Cloner ou copier le projet
cd flight-agent-team

# 2. Vérifier l'installation (optionnel)
bash scripts/setup.sh

# 3. Lancer Claude Code
claude
```

Aucune clé API requise. Le serveur MCP `google-flights-mcp-server` s'installe automatiquement via npx au premier lancement.

---

## Structure du projet

```
flight-agent-team/
├── CLAUDE.md                    ← Cerveau : workflow Scan & Snipe, règles, mémoire
├── .claude/
│   ├── settings.json            ← Serveur MCP Google Flights (npx, pas de clé API)
│   └── agents/
│       └── flight-sniper.md     ← Agent de recherche (lancé N fois en parallèle)
├── data/
│   ├── airline-fees.md          ← Frais cachés par type de compagnie
│   ├── airport-alternatives.md  ← Aéroports alternatifs + coût transport
│   └── memory/
│       ├── MEMORY.md            ← Index de la mémoire
│       ├── user-preferences.md  ← Préférences persistantes
│       └── search-history.md    ← Historique des recherches et prix
├── docs/
│   └── guide.md                 ← Guide utilisateur détaillé
└── scripts/
    └── setup.sh                 ← Script d'installation
```

---

## Exemples d'utilisation

### Recherche simple
```
Trouve-moi un vol Paris-New York du 15 au 22 mars
```

### Trouver les dates les moins chères
```
Quand est-ce le moins cher pour aller à Tokyo depuis Paris en mars ?
```
> Flight Sniper scanne la grille de prix sur ~60 jours et vous montre les dates optimales.

### Budget serré
```
Vol le moins cher possible Paris-Bangkok en avril, je suis flexible ±7 jours
```

### Confort prioritaire
```
Paris-Tokyo en mars, je veux du confort, budget 1200€ max, vol direct si possible
```

### Multi-villes
```
Paris → Bangkok → Tokyo → Paris en avril, 3 semaines au total
```

---

## Serveur MCP

Flight Sniper utilise **google-flights-mcp-server** — un serveur MCP qui interroge Google Flights directement (pas de scraping, protocole protobuf).

**Outils disponibles :**

| Outil | Description |
|-------|-------------|
| `search_flights` | Recherche de vols avec filtres (classe, escales, tri, pagination) |
| `get_date_grid` | Grille de prix sur ~60 jours — trouve les dates les moins chères |
| `find_airport_code` | Résolution de noms de villes/aéroports en codes IATA |

**Configuration** (déjà pré-configurée dans `.claude/settings.json`) :
```json
{
  "mcpServers": {
    "google-flights": {
      "command": "npx",
      "args": ["-y", "google-flights-mcp-server"]
    }
  }
}
```

### Ajouter une source MCP supplémentaire

Pour de meilleurs résultats, vous pouvez ajouter une 2e source dans `.claude/settings.json` :

**Aviasales (findflights.me) — quand le serveur est disponible :**
```json
{
  "mcpServers": {
    "google-flights": {
      "command": "npx",
      "args": ["-y", "google-flights-mcp-server"]
    },
    "flights-mcp": {
      "type": "sse",
      "url": "https://findflights.me/sse"
    }
  }
}
```

---

## Mémoire persistante

Flight Sniper se souvient de vos préférences et de vos recherches passées entre les sessions.

**Préférences** (`data/memory/user-preferences.md`) :
- Aéroports de départ habituels
- Besoins en bagages
- Préférences de confort et budget

**Historique** (`data/memory/search-history.md`) :
- Routes déjà recherchées avec prix trouvés
- Permet de comparer l'évolution des prix dans le temps

Ces fichiers sont mis à jour automatiquement après chaque recherche.

---

## Personnalisation

### Modifier les frais cachés
Éditez `data/airline-fees.md` pour mettre à jour les montants ou ajouter des compagnies.

### Ajouter des aéroports
Éditez `data/airport-alternatives.md` pour ajouter des villes ou des aéroports alternatifs.

### Ajuster les règles métier
Éditez `CLAUDE.md` pour modifier :
- Le nombre d'instances parallèles (2-4 par défaut)
- Le seuil de préférence pour les vols directs (20% par défaut)
- Le format de sortie des recommandations

---

## Limites connues

- **Prix indicatifs** — les prix via Google Flights sont des estimations en temps réel. Le prix final peut varier au moment de la réservation
- **Pas de booking direct** — Flight Sniper trouve et compare, la réservation se fait sur le site de la compagnie
- **Rate limiting** — le serveur MCP a un rate limiter intégré pour éviter le throttling. Les recherches très volumineuses peuvent être ralenties
- **Couverture** — Google Flights couvre la majorité des routes commerciales mondiales

---

## Coûts

| Composant | Coût |
|-----------|------|
| Claude Code (Pro) | ~20$/mois |
| google-flights-mcp-server | Gratuit (aucune clé API) |

---

## Licence

MIT
