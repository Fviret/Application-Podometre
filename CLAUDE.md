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

## Roadmap / Features à venir

- [ ] Objectif personnalisable (remplacer le 10 000 pas en dur)
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
