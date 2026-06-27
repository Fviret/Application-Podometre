# Pedometer App — CLAUDE.md

## Contexte projet

Application iOS de suivi de pas quotidiens, développée en Swift/SwiftUI.
Projet personnel à but de portfolio et storytelling LinkedIn ("build in public").
Développement incrémental solo, sans dépendances tierces.

---

## Stack

- **Langage** : Swift 5.9+
- **UI** : SwiftUI pur (pas de UIKit, pas de Swift Charts)
- **Données** : HealthKit — `stepCount` pour les pas, `distanceWalkingRunning` pour les trajets
- **Notifications** : `UserNotifications` (UNUserNotificationCenter)
- **Cible** : iOS 17+ minimum
- **Outil** : Xcode, Claude Code pour le développement assisté

---

## Architecture

**MVVM** — pattern standard SwiftUI.

- `ObservableObject` + `@Published` pour les ViewModels et services (pas `@Observable`)
- Un fichier par View
- Un ViewModel par écran principal (`StepCountViewModel` pour l'activité)
- Les appels HealthKit sont isolés dans les ViewModels/services — jamais dans les Views
- Les services partagés sont injectés via `@EnvironmentObject` depuis `ContentView`

### Services partagés

| Service | Rôle | Injection |
|---|---|---|
| `StepCountViewModel` | Pas, objectif, streak, badges, couleur anneau | `@StateObject` dans `ContentView` |
| `JourneyProgressService` | Progression des trajets, distance HK, completion | `@EnvironmentObject` |

### Communication entre services
Le pattern retenu est le **callback** : `JourneyProgressService.onJourneyCompleted` est câblé dans `ContentView` vers `StepCountViewModel.markJourneyCompleted`. Préférer ce pattern à `NotificationCenter` pour les échanges entre services.

---

## Fonctionnalités implémentées

### Anneau de progression
- Cercle rempli proportionnellement à l'objectif (défaut : 10 000 pas)
- Affiche les pas du jour en cours en temps réel via `HKObserverQuery`
- Couleur personnalisable (picker 6 couleurs, persisté UserDefaults)

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
- Inclut le jour en cours via `stepCount` live

### Paramètres
- Objectif quotidien : picker 5 000–20 000 pas
- Couleur de l'anneau : 6 presets (`AppColors.ringColorOptions`), propagée partout
- Notifications : toggle objectif journalier (1x/jour max)
- Mode sombre : toggle, appliqué via `.preferredColorScheme` sur le `TabView`
- Streak : série de jours consécutifs (flamme 🔥), cachée si streak = 0
- Badges : grille de seuils de pas (5k→100k avec compteur) + badges de trajets (emoji)

### Système de trajets
- 19 trajets dans 4 catégories : Promenades, Sentiers, Histoire, Mythes & Épopées
- Progression via `distanceWalkingRunning` depuis `startDate` (requête idempotente)
- `HKObserverQuery` live sur la distance — mise à jour sans ouvrir la vue
- Jalons (milestones) débloqués au fil du km, avec notification locale
- Completion : badge débloqué + notification + état "Terminé" dans l'UI

---

## UserDefaults — clés en production

| Clé | Type | Rôle |
|---|---|---|
| `dailyStepGoal` | `Int` | Objectif quotidien en pas |
| `ringColorId` | `String` | ID de la couleur de l'anneau |
| `notificationsEnabled` | `Bool` | Toggle notification objectif |
| `goalNotifiedDate` | `Date` | Garde pour max 1 notif/jour |
| `isDarkMode` | `Bool` | Toggle mode sombre |
| `completedJourneyIds` | `[String]` | UUIDs des trajets terminés |
| `journeyProgressMap` | `Data` (JSON) | `[UUID: JourneyProgress]` encodé |

Ne pas créer de nouvelles clés sans les ajouter ici.

---

## Conventions

- **Nommage** : anglais pour le code, commentaires en français si nécessaire
- **Pas de force unwrap** (`!`) — utiliser `guard let` ou `if let`
- **Pas de dépendances externes** — SwiftUI pur uniquement
- **Simulateur** : toujours ajouter `#if targetEnvironment(simulator)` avec des données mock réalistes

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

```swift
// Requête HK idempotente — recalculer depuis startDate, ne jamais incrémenter
let km = await fetchDistance(from: progress.startDate)
guard km > progress.totalKm else { return }
progress.totalKm = km
```

```swift
// Communication entre services — callback plutôt que NotificationCenter
journeyProgressService.onJourneyCompleted = { id in
    viewModel.markJourneyCompleted(id)
}
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
- [x] Système de trajets avec progression HealthKit distance
- [x] Badges de pas et de trajets
- [x] Streak de jours consécutifs
- [x] Notifications locales (objectif + jalons + completion)
- [x] Couleur de l'anneau personnalisable
- [x] Mode sombre
- [ ] Widget iOS écran d'accueil
- [ ] Export CSV des données
- [ ] Gamification RPG — débloquer des actions selon les pas (concept en cours d'évaluation)

---

## Ce qu'il ne faut pas faire

- Ne pas utiliser `UIKit` sauf si SwiftUI ne permet vraiment pas
- Ne pas introduire de packages Swift (SPM) sans décision explicite
- Ne pas stocker les données HealthKit localement — toujours lire depuis HK
- Ne pas casser la navigation par chevrons en ajoutant des limites arbitraires de jours
- Ne pas utiliser `@Observable` — le projet utilise `ObservableObject` / `@Published`
- Ne pas créer de clé UserDefaults sans la documenter dans la table ci-dessus
- Ne pas utiliser `gridCellColumns(_:)` dans un `LazyVGrid` — ça ne fonctionne pas (réservé à `Grid`)

---

## Autorisations HealthKit requises (Info.plist)

```
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription
NSUserNotificationsUsageDescription
```

Types HK lus : `stepCount`, `distanceWalkingRunning`

Capacité HealthKit activée dans les entitlements du projet.
