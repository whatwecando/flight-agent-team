# Guide d'utilisation — Flight Sniper

## Démarrage rapide

```bash
# 1. Se placer dans le projet
cd flight-agent-team

# 2. Lancer Claude Code
claude

# 3. Poser votre question
# Exemple : "Trouve-moi un vol Paris-Tokyo du 15 au 22 mars"
```

Claude va automatiquement :
1. Analyser vos critères
2. **Scanner la grille de prix** sur ~60 jours pour identifier les meilleures dates
3. Lancer plusieurs recherches en parallèle sur les dates/aéroports optimaux
4. Calculer le **Coût Total Réel** de chaque option
5. Vous présenter le TOP 5 avec recommandation
6. **Sauvegarder** vos préférences et l'historique pour les prochaines sessions

---

## Exemples de requêtes

### 1. Recherche simple

```
Trouve-moi un vol Paris-New York du 15 au 22 mars
```

**Ce qui se passe en coulisses :**
- L'orchestrateur résout "Paris" → CDG et "New York" → JFK via `find_airport_code`
- Il scanne la grille de prix avec `get_date_grid` sur CDG→JFK
- Il identifie les dates les moins chères autour du 15-22 mars
- Il lance 3 snipers en parallèle : dates exactes, dates optimales, EWR comme alternative
- Il calcule le Coût Total Réel pour chaque option
- Il présente le TOP 5

### 2. Trouver les dates les moins chères

```
Quand est-ce le moins cher pour aller à Tokyo depuis Paris en mars ?
```

**Ce qui se passe :**
- `get_date_grid` scanne les prix CDG→NRT et CDG→HND sur tout mars + avril
- L'orchestrateur identifie les dates les moins chères (ex: mardi 12 mars à 450€ vs samedi 15 à 620€)
- Il propose les 3 meilleures fenêtres de dates avec prix estimés

### 3. Budget serré

```
Vol le moins cher possible Paris-Bangkok en avril, je suis flexible ±7 jours
```

**Ce qui se passe :**
- Flexibilité détectée → scan large sur tout avril
- Aéroports : CDG + ORY → BKK + DMK
- Les dates les moins chères sont identifiées par le scan
- Snipers lancés sur les dates optimales trouvées
- Le Coût Total Réel inclut les bagages (important pour les low-cost sur cette route)

### 4. Confort prioritaire

```
Paris-Tokyo en mars, je veux du confort, budget 1200€ max, vol direct si possible
```

**Ce qui se passe :**
- Préférence "confort" → focus sur full-service (Air France, ANA, JAL)
- Vol direct CDG→HND/NRT priorisé
- Haneda préféré à Narita (plus proche du centre, moins cher en transport)
- Surcoût = 0€ pour ces compagnies (tout inclus en éco)

### 5. Dernière minute

```
Vol pour Lisbonne ce weekend, le moins cher possible
```

**Ce qui se passe :**
- Scan de la grille de prix sur les prochains jours
- Tous les aéroports Paris (CDG, ORY, BVA)
- Toutes les compagnies (TAP, Transavia, EasyJet, Ryanair, Vueling)
- Alerte si prix anormalement élevé (dernière minute = souvent cher)

---

## Comprendre les résultats

### Le Coût Total Réel (CTR)

C'est LA métrique clé de Flight Sniper. Au lieu de comparer les prix affichés (souvent trompeurs), on compare les **vrais coûts** :

```
┌─────────────────────────────────────────────────┐
│ Option #1 — Ryanair FR1234                      │
│                                                 │
│ Prix affiché :           89€                    │
│ + Bagage cabine 10kg :  +25€                    │
│ + Bagage soute 20kg :   +35€                    │
│ + Transport BVA :       +17€ (bus Beauvais)     │
│ ────────────────────────────────                │
│ COÛT TOTAL RÉEL :       166€                    │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ Option #2 — Air France AF9012                   │
│                                                 │
│ Prix affiché :          175€                    │
│ + Surcoûts :            +0€ (tout inclus)       │
│ + Transport CDG :       +11€                    │
│ ────────────────────────────────────────────────│
│ COÛT TOTAL RÉEL :       186€                    │
└─────────────────────────────────────────────────┘
```

**Résultat :** Ryanair à 89€ semble 2× moins cher qu'Air France à 175€. En réalité, l'écart est de 166€ vs 186€ = seulement 20€. Et avec Air France, vous avez le confort, les bagages, et un aéroport mieux desservi.

### La grille de prix (Date Grid)

Quand Flight Sniper scanne les prix, il vous montre quelque chose comme :

```
Grille de prix CDG → NRT (mars 2026)

Lun   Mar   Mer   Jeu   Ven   Sam   Dim
                                480€  520€
490€  450€  455€  470€  510€  620€  580€
500€  448€  460€  475€  505€  610€  570€
495€  452€  458€  480€  515€  630€  590€

→ Les mardis sont 25-30% moins chers que les samedis
→ Meilleur prix : mardi 12 mars à 448€
```

### Les alertes et pièges

Flight Sniper signale automatiquement :
- ⚠️ **Escale longue** — plus de 4h de correspondance
- ⚠️ **Changement d'aéroport** — deux aéroports différents en transit
- ⚠️ **Arrivée J+1** — le vol arrive le lendemain
- ⚠️ **Correspondance risquée** — moins de 1h30 (2h international)
- ⚠️ **Visa transit** — pays nécessitant un visa même en transit
- ⚠️ **Tarif nu** — prix ultra-low-cost sans bagages

---

## La mémoire de Flight Sniper

Flight Sniper se souvient de vous entre les sessions.

### Préférences automatiques

Après quelques recherches, il saura :
- Votre aéroport de départ habituel (plus besoin de préciser "depuis Paris")
- Vos besoins en bagages (cabine seul ou soute)
- Votre sensibilité prix vs confort
- Vos compagnies préférées ou évitées

### Suivi des prix

Si vous recherchez la même route plusieurs fois :
```
"La dernière fois que vous avez cherché Paris→Tokyo (il y a 5 jours),
le meilleur prix était 480€ CTR (ANA). Aujourd'hui : 465€ CTR.
Le prix a baissé de 15€ (-3%)."
```

### Fichiers mémoire

- `data/memory/user-preferences.md` — vos préférences (éditables manuellement)
- `data/memory/search-history.md` — historique des recherches

---

## Scénario complet commenté

### Recherche Paris → Tokyo, 15-22 mars

**Vous tapez :**
```
Trouve le meilleur vol Paris-Tokyo du 15 au 22 mars, j'ai besoin d'un bagage soute
```

**Étape 1 — Comprendre :**
L'orchestrateur extrait : CDG→TYO, 15-22 mars, 1 passager, 1 bagage soute.
Il consulte la mémoire : c'est votre première recherche, pas de préférences connues.

**Étape 2 — Scanner :**
`get_date_grid` sur CDG→NRT et CDG→HND pour tout mars.
Résultat : mardi 12 mars (450€) et mercredi 20 mars (465€) sont les dates les moins chères.
Samedi 15 mars : 620€ (votre date = +170€ vs meilleur jour).

**Étape 3 — Sniper parallèle :**
3 instances lancées simultanément :
1. CDG→HND, 15→22 mars (vos dates exactes)
2. CDG→HND, 12→20 mars (dates optimales du scan)
3. CDG→NRT, 15→22 mars (Narita, pour diversité)

**Étape 4 — Analyser :**
Pour chaque option, calcul du CTR via `data/airline-fees.md` :
- ANA direct CDG→HND 12→20 : 450€, 2×23kg inclus → **CTR = 453€**
- Air France direct CDG→HND 15→22 : 650€, tout inclus → **CTR = 653€**
- Turkish via IST CDG→NRT 15→22 : 480€, tout inclus → **CTR = 500€** (+20€ Narita Express)
- JAL direct CDG→NRT 12→20 : 470€, 2×23kg inclus → **CTR = 490€**

**Étape 5 — Recommander :**
- **Best value :** ANA direct vers Haneda, 12→20 mars — 453€ CTR
- **Sur vos dates :** Turkish via Istanbul — 500€ CTR (bon compromis)
- **Plus confortable sur vos dates :** Air France direct vers Haneda — 653€ CTR
- **Conseil dates :** "En décalant au mardi 12 mars, vous économisez 200€"

**Mémoire mise à jour :**
- Préférences : aéroport CDG, bagage soute nécessaire
- Historique : Paris→Tokyo, meilleur CTR 453€ (ANA)

---

## Astuces

### Obtenir de meilleurs résultats

1. **Précisez vos bagages** — "j'ai besoin d'un bagage soute" change radicalement le classement
2. **Indiquez votre flexibilité** — "je suis flexible ±7 jours" déclenche un scan large
3. **Mentionnez vos priorités** — "confort", "le moins cher", "le plus rapide"
4. **Demandez la grille de prix** — "quand est-ce le moins cher pour aller à X ?" utilise le scan de dates

### Forcer un angle de recherche

```
Cherche uniquement des vols Turkish Airlines via Istanbul pour Paris-Tokyo
```

```
Compare les prix depuis CDG, ORY et BVA pour un vol vers Londres
```

```
Montre-moi la grille de prix Paris-Lisbonne pour tout le mois de juin
```

---

## FAQ

**Q : Les prix sont-ils garantis ?**
Non. Les prix proviennent de Google Flights en temps réel. Le prix final peut varier au moment de la réservation.

**Q : Faut-il une clé API ?**
Non. Le serveur MCP `google-flights-mcp-server` fonctionne sans clé API.

**Q : Puis-je réserver directement ?**
Flight Sniper trouve et compare les vols. La réservation se fait sur le site de la compagnie aérienne.

**Q : Comment réinitialiser la mémoire ?**
Videz les fichiers `data/memory/user-preferences.md` et `data/memory/search-history.md`.

**Q : Ça marche pour les vols intérieurs ?**
Oui, tant que la route est couverte par Google Flights (quasi-toutes les routes commerciales mondiales).

**Q : Qu'est-ce que le Coût Total Réel ?**
C'est le prix que vous payerez vraiment : prix du billet + bagages + siège + transport aéroport alternatif. Voir la section "Comprendre les résultats" ci-dessus.
