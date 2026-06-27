# Pedometer App — CLAUDE.md

## Contexte projet

Application iOS de suivi de pas quotidiens, développée en Swift/SwiftUI.
Projet personnel à but de portfolio et storytelling LinkedIn ("build in public").
Développement incrémental solo, sans dépendances tierces.

---

## Stack

- **Langage** : Swift 5.9+
- **UI** : SwiftUI pur (pas de UIKit, pas de Swift Charts)
- **Données** : HealthKit — lecture des pas via `HKQuantityTypeIdentifier.stepCount`
- **Cible** : iOS 17+ minimum
- **Outil** : Xcode, Claude Code pour le développement assisté

---

## Architecture

**MVVM** — pattern standard SwiftUI.

- `@Observable` pour les ViewModels (pas de `ObservableObject` / `@Published`)
- Un fichier par View
- Un ViewModel par écran principal
- Les appels HealthKit sont isolés dans un service dédié (`HealthKitService` ou similaire)

---

## Fonctionnalités implémentées

### Anneau de progression
- Cercle rempli proportionnellement à l'objectif (défaut : 10 000 pas)
- Affiche les pas du jour en cours en temps réel

### Navigation par jour
- Chevrons natifs SF Symbol (`chevron.left` / `chevron.right`)
- Chevron gauche toujours visible (pas de limite à 6 jours)
- Pattern "ghost slot" pour maintenir le centrage : `.opacity(0).disabled(true)`

### Calendrier mensuel
- Grille des jours du mois
- Cercle plein = objectif atteint, cercle vide = non atteint
- Calcul du premier jour de semaine via `firstWeekday` (bug corrigé : alignement grille)

### Graphe hebdomadaire
- Courbe linéaire maison (sans Swift Charts)
- Compare semaine en cours vs semaine précédente
- Inclut le jour en cours via `stepCount` live (pas uniquement les jours complétés)

---

## Conventions

- **Nommage** : anglais pour le code, commentaires en français si nécessaire
- **Pas de force unwrap** (`!`) — utiliser `guard let` ou `if let`
- **Pas de dépendances externes** — SwiftUI pur uniquement
- **Prompts Claude Code** : structure modulaire avec sections nommées
  - Contexte projet / Architecture / État actuel / Instruction du jour / Contraintes

### Documentation des fonctions

Toute fonction ou propriété calculée non triviale doit être documentée avec un commentaire `///` en français.

- **Structs et classes** : doc sur la déclaration (rôle global)
- **Fonctions publiques/internes** : doc systématique — ce qu'elle fait, ses effets de bord notables
- **Fonctions privées** : doc si la logique n'est pas évidente à la lecture
- **Propriétés `@Published`** : doc sur la sémantique (unité, plage, convention d'index)

```swift
/// Retourne le tableau plat de numéros de jours pour la grille du mois.
/// Les cellules `nil` sont des espaces vides avant le 1er ou en fin de grille.
private func calendarDays(for month: Date) -> [Int?] { … }
```

Ne pas documenter les fonctions dont le nom suffit (`isFuture`, `date(forDay:)`, etc.).

---

## Patterns à respecter

```swift
// Ghost slot pour maintenir le centrage d'un élément conditionnel
Color.clear
    .frame(width: 44, height: 44)
    .opacity(0)
    .disabled(true)
```

```swift
// Calcul premier jour du mois (bug connu : toujours tester l'alignement)
let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
```

---

## Workflow Git

Chaque feature est développée sur sa propre branche et mergée directement dans `main` sans PR.

### Conventions de nommage des branches

```
feature/<nom-court>     # nouvelle fonctionnalité
fix/<nom-court>         # correction de bug
refactor/<nom-court>    # refactoring sans changement fonctionnel
```

Exemples : `feature/journey-detail`, `fix/calendar-alignment`, `refactor/healthkit-service`

### Workflow standard

```bash
# 1. Créer la branche depuis main à jour
git checkout main && git pull origin main
git checkout -b feature/<nom>

# 2. Développer, committer au fil de l'eau
git add <fichiers>
git commit -m "message"

# 3. Merger dans main et pousser
git checkout main
git merge --no-ff feature/<nom> -m "Merge feature/<nom>"
git push origin main

# 4. Nettoyer la branche
git branch -d feature/<nom>
git push origin --delete feature/<nom>
```

### Règles

- Travailler sur une branche dédiée par feature (jamais directement sur `main`)
- Un dossier feature (`Ring/`, `Settings/`, `Journey/`, …) = une branche dédiée lors de sa création
- Merger avec `--no-ff` pour garder une trace claire des features dans le log

---

## Roadmap / Features à venir

- [x] Objectif personnalisable (picker 5 000–20 000 dans les paramètres, persisté UserDefaults)
- [ ] Gamification RPG — débloquer des actions selon les pas (concept en cours d'évaluation)
- [ ] Widget iOS écran d'accueil
- [ ] Notifications de rappel
- [ ] Export CSV des données

---

## Ce qu'il ne faut pas faire

- Ne pas utiliser `UIKit` sauf si SwiftUI ne permet vraiment pas
- Ne pas introduire de packages Swift (SPM) sans décision explicite
- Ne pas stocker les données HealthKit localement — toujours lire depuis HK
- Ne pas casser la navigation par chevrons en ajoutant des limites arbitraires de jours

---

## Autorisations HealthKit requises (Info.plist)

```
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription
```

Capacité HealthKit activée dans les entitlements du projet.
