# Flight Sniper

**Trouvez le vrai meilleur prix, pas le prix d'appel.**

Flight Sniper est un système de recherche de vols basé sur Claude Code qui utilise une architecture innovante de **snipe parallèle** pour explorer plusieurs angles de recherche simultanément et calculer le **Coût Total Réel** de chaque option (prix affiché + bagages + frais cachés + transport aéroport).

```
 "Paris → Tokyo, 15-22 mars"
          │
     CLAUDE.md (orchestrateur)
          │
          ├── 1. Comprendre les critères
          ├── 2. Élargir le périmètre (dates flex, aéroports alt)
          │
          ├── 3. Snipe parallèle
          │      ├──► Sniper #1 : CDG→NRT dates exactes
          │      ├──► Sniper #2 : CDG→HND dates ±3j
          │      ├──► Sniper #3 : ORY→NRT mardi/mercredi
          │      └──► Sniper #4 : split aller/retour
          │             (en parallèle)
          │
          ├── 4. Analyser — Coût Total Réel
          │      prix + bagages + siège + transport + frais CB
          │
          └── 5. Recommander — TOP 5 + pièges détectés
```

## Ce qui rend Flight Sniper différent

| Approche classique | Flight Sniper |
|-------------------|---------------|
| 1 recherche, 1 résultat | N recherches en parallèle, N angles différents |
| Prix affiché = prix final | **Coût Total Réel** = prix + tous les frais cachés |
| Pas de contexte sur les compagnies | Base de connaissances des frais par compagnie |
| Aéroport unique | Aéroports alternatifs avec coût de transport |
| Pipeline séquentiel (recherche → comparaison → optimisation) | Un seul agent sniper × N instances parallèles |

---

## Prérequis

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installé
- Abonnement Claude (Pro ou Team)

## Installation

```bash
# 1. Cloner ou copier le projet
cd flight-agent-team

# 2. Vérifier l'installation (optionnel)
bash scripts/setup.sh

# 3. Lancer Claude Code
claude
```

C'est tout. Le serveur MCP `findflights.me` est pré-configuré et ne nécessite pas de clé API.

---

## Structure du projet

```
flight-agent-team/
├── CLAUDE.md                    ← Cerveau : workflow, règles métier, orchestration
├── .claude/
│   ├── settings.json            ← Serveur MCP + permissions
│   └── agents/
│       └── flight-sniper.md     ← Agent de recherche (lancé N fois en parallèle)
├── data/
│   ├── airline-fees.md          ← Frais cachés par type de compagnie
│   └── airport-alternatives.md  ← Aéroports alternatifs + coût transport
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

### Dernière minute
```
Il me faut un vol pour Lisbonne ce weekend, le moins cher possible
```

---

## Ajouter une 2e source MCP (Google Flights)

Le projet est pré-configuré avec `findflights.me` (Aviasales). Pour ajouter Google Flights comme 2e source :

### Option A — Google Flights via SerpAPI

1. Cloner le serveur MCP : `git clone https://github.com/arjunprabhulal/mcp-flight-search.git`
2. Obtenir une clé API sur [serpapi.com](https://serpapi.com) (50 recherches gratuites/mois)
3. Ajouter dans `.claude/settings.json` :

```json
{
  "mcpServers": {
    "flights-mcp": {
      "type": "sse",
      "url": "https://findflights.me/sse"
    },
    "google-flights": {
      "command": "python",
      "args": ["-m", "mcp_flight_search.server"],
      "cwd": "/chemin/vers/mcp-flight-search",
      "env": {
        "SERPAPI_KEY": "votre-clé-ici"
      }
    }
  }
}
```

4. Ajouter les permissions correspondantes dans `permissions.allow`
5. Mettre à jour `flight-sniper.md` pour utiliser les deux sources

### Option B — Amadeus API

1. Créer un compte sur [developers.amadeus.com](https://developers.amadeus.com)
2. Obtenir les clés API (environnement test gratuit)
3. Utiliser un serveur MCP Amadeus compatible

---

## Personnalisation

### Modifier les frais cachés
Éditez `data/airline-fees.md` pour mettre à jour les montants ou ajouter des compagnies.

### Ajouter des aéroports
Éditez `data/airport-alternatives.md` pour ajouter des villes ou des aéroports alternatifs.

### Ajuster les règles métier
Éditez `CLAUDE.md` pour modifier :
- Le nombre d'instances parallèles (3-5 par défaut)
- La flexibilité des dates (±3j ou ±7j)
- Le seuil de préférence pour les vols directs (20% par défaut)
- Le format de sortie des recommandations

---

## Limites connues

- **Prix indicatifs** — les prix retournés par les API sont des estimations. Le prix final peut varier au moment de la réservation
- **Pas de booking direct** — Flight Sniper trouve et compare, mais la réservation se fait sur le site de la compagnie ou de l'OTA
- **Source unique par défaut** — seul findflights.me est pré-configuré. Ajouter une 2e source améliore significativement la couverture
- **Disponibilité MCP** — si findflights.me est indisponible, les recherches échoueront. L'agent signalera l'erreur
- **Frais estimés** — la base `airline-fees.md` contient des estimations qui peuvent évoluer. Vérifier sur le site de la compagnie avant de réserver

---

## Coûts estimés

| Composant | Coût |
|-----------|------|
| Claude Code (Pro) | ~20$/mois |
| findflights.me MCP | Gratuit |
| SerpAPI (Google Flights) | 50 recherches gratuites/mois, puis 50$/mois |
| Amadeus API (test) | Gratuit (rate-limited) |

---

## Licence

MIT
