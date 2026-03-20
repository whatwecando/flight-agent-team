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
2. Élargir la recherche (dates flexibles, aéroports alternatifs)
3. Lancer plusieurs recherches en parallèle
4. Calculer le coût total réel de chaque option
5. Vous présenter le TOP 5 avec recommandation

---

## Exemples de requêtes

### 1. Recherche simple

```
Trouve-moi un vol Paris-New York du 15 au 22 mars
```

**Ce qui se passe en coulisses :**
- L'orchestrateur identifie : CDG → JFK, 15-22 mars
- Il élargit : CDG + ORY → JFK + EWR, 12-18 mars → 19-25 mars
- Il lance 3-4 snipers en parallèle sur différentes combinaisons
- Il calcule le Coût Total Réel pour chaque option
- Il présente le TOP 5

### 2. Budget serré

```
Vol le moins cher possible Paris-Bangkok en avril, je suis flexible sur les dates
```

**Ce qui se passe :**
- Flexibilité détectée → recherche élargie à ±7 jours
- Aéroports : CDG + ORY → BKK + DMK
- Stratégies : aller-retour combiné + split aller/retour + via hub (IST, DOH)
- Focus sur mardi/mercredi (jours les moins chers)
- Le Coût Total Réel inclura les bagages (important pour les low-cost sur cette route)

### 3. Confort prioritaire

```
Paris-Tokyo en mars, je veux du confort, budget 1200€ max, vol direct si possible
```

**Ce qui se passe :**
- Préférence "confort" → focus sur full-service (Air France, ANA, JAL)
- Vol direct CDG→HND/NRT priorisé
- Haneda préféré à Narita (plus proche du centre, moins cher en transport)
- Surcoût = 0€ pour ces compagnies (tout inclus en éco)

### 4. Multi-villes

```
Paris → Bangkok → Tokyo → Paris en avril, 3 semaines
```

**Ce qui se passe :**
- Découpage en 3 segments : CDG→BKK, BKK→NRT/HND, NRT/HND→CDG
- Chaque segment recherché indépendamment en parallèle
- Vérification que les correspondances sont faisables (min 4h entre vols)
- Calcul du coût total combiné

### 5. Dernière minute

```
Vol pour Lisbonne ce weekend, le moins cher possible
```

**Ce qui se passe :**
- Recherche sur vendredi-samedi aller, dimanche-lundi retour
- Tous les aéroports Paris (CDG, ORY, BVA)
- Toutes les compagnies (TAP, Transavia, EasyJet, Ryanair, Vueling)
- Alerte si prix anormalement élevé (dernière minute = souvent cher)

---

## Comprendre les résultats

### Le Coût Total Réel

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
│ Option #2 — Transavia TO5678                    │
│                                                 │
│ Prix affiché :          139€                    │
│ + Bagage soute 23kg :   +25€                    │
│ + Transport ORY :       +13€                    │
│ ────────────────────────────────────────────────│
│ COÛT TOTAL RÉEL :       177€                    │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ Option #3 — Air France AF9012                   │
│                                                 │
│ Prix affiché :          175€                    │
│ + Surcoûts :            +0€ (tout inclus)       │
│ + Transport CDG :       +11€                    │
│ ────────────────────────────────────────────────│
│ COÛT TOTAL RÉEL :       186€                    │
└─────────────────────────────────────────────────┘
```

**Résultat :** Ryanair à 89€ semble 2× moins cher qu'Air France à 175€. En réalité, l'écart est de 166€ vs 186€ = seulement 20€. Et avec Air France, vous avez le confort, les bagages, et un aéroport mieux desservi.

### Les alertes et pièges

Flight Sniper signale automatiquement :
- ⚠️ **Escale longue** — plus de 4h de correspondance
- ⚠️ **Changement d'aéroport** — deux aéroports différents en transit
- ⚠️ **Arrivée J+1** — le vol arrive le lendemain
- ⚠️ **Correspondance risquée** — moins de 1h30 (2h international)
- ⚠️ **Visa transit** — pays nécessitant un visa même en transit
- ⚠️ **Tarif nu** — prix ultra-low-cost sans bagages

---

## Scénario complet commenté

### Recherche Paris → Tokyo, 15-22 mars

**Vous tapez :**
```
Trouve le meilleur vol Paris-Tokyo du 15 au 22 mars, j'ai besoin d'un bagage soute
```

**Étape 1 — Comprendre :**
L'orchestrateur extrait : CDG→TYO (Tokyo), 15-22 mars, 1 passager, 1 bagage soute nécessaire.

**Étape 2 — Élargir :**
- Dates : 12-18 mars → 19-25 mars (±3j)
- Aéroports Paris : CDG (principal), ORY (si applicable)
- Aéroports Tokyo : NRT + HND (Haneda préféré)
- Stratégies : direct, via IST (Turkish), via DOH (Qatar)

**Étape 3 — Sniper parallèle :**
4 instances lancées simultanément :
1. CDG→HND, dates exactes 15→22 mars
2. CDG→NRT, dates mardi 12 → mercredi 20 mars
3. CDG→HND, via IST (Turkish Airlines)
4. CDG→NRT, split aller/retour

**Étape 4 — Analyser :**
Résultats collectés. Pour chaque option :
- Air France direct CDG→HND : 650€, tout inclus → **CTR = 653€** (+3€ RER)
- ANA direct CDG→HND : 620€, 2×23kg inclus → **CTR = 623€** (+3€ monorail)
- Turkish via IST CDG→IST→NRT : 480€, tout inclus → **CTR = 500€** (+20€ Narita Express)
- JAL direct CDG→NRT : 680€, 2×23kg inclus → **CTR = 700€** (+20€ Narita Express)

**Étape 5 — Recommander :**
- **Best value :** Turkish Airlines via IST — 500€ CTR (excellent rapport qualité/prix, escale raisonnable)
- **Moins cher :** Turkish Airlines — même vol
- **Plus confortable :** ANA direct vers Haneda — 623€ CTR (direct, Haneda proche du centre, 2 bagages inclus)

---

## Astuces

### Obtenir de meilleurs résultats

1. **Précisez vos bagages** — "j'ai besoin d'un bagage soute" change radicalement le classement
2. **Indiquez votre flexibilité** — "je suis flexible ±7 jours" ouvre plus d'options
3. **Mentionnez vos priorités** — "confort", "le moins cher", "le plus rapide" adapte la stratégie
4. **Aéroport de départ précis** — "depuis Orly" évite des recherches inutiles

### Jours les moins chers

- **Mardi et mercredi** sont statistiquement les jours les moins chers pour voler
- **Samedi** est souvent le jour le plus cher
- **Réserver 6-8 semaines à l'avance** pour le meilleur prix en Europe, 2-3 mois pour le long-courrier
- **Éviter** les veilles de jours fériés et les débuts/fins de vacances scolaires

### Forcer un angle de recherche

```
Cherche uniquement des vols Turkish Airlines via Istanbul pour Paris-Tokyo
```

```
Compare les prix depuis CDG, ORY et BVA pour un vol vers Londres
```

---

## FAQ

**Q : Les prix sont-ils garantis ?**
Non. Les prix retournés sont des estimations en temps réel via l'API Aviasales. Le prix final peut varier au moment de la réservation.

**Q : Puis-je réserver directement ?**
Flight Sniper vous fournit des liens de réservation quand ils sont disponibles. La réservation se fait sur le site de la compagnie ou de l'OTA.

**Q : Comment ajouter plus de sources de données ?**
Voir la section "Ajouter une 2e source MCP" dans le README. Google Flights via SerpAPI est recommandé comme 2e source.

**Q : Les frais cachés sont-ils à jour ?**
La base `data/airline-fees.md` contient des estimations 2025-2026. Vérifiez toujours sur le site de la compagnie avant de réserver. Vous pouvez mettre à jour ce fichier vous-même.

**Q : Ça marche pour les vols intérieurs ?**
Oui, tant que la route est couverte par Aviasales. La couverture est excellente pour l'Europe et l'international, variable pour les vols domestiques hors Europe.
