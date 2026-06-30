# Pedometer App — CLAUDE.md

<!-- last updated: 2025-06-30 — À mettre à jour à chaque fin de session -->

---

## Contexte de reprise

> **À mettre à jour manuellement avant de clore chaque session Claude Code.**

| Champ | Valeur |
|---|---|
| Branche active | `dev` |
| Dernière feature travaillée | — |
| Fichiers modifiés récemment | — |
| Bugs ouverts connus | — |
| Prochaine tâche prévue | — |

---

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
- Un fichier par View — suffixe `View` systématique (ex : `StepRingView`, `JourneyListView`, `SettingsView`)
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

## Arborescence du projet

```
Pedometer/
├── App/
│   └── PedometerApp.swift          # @main, point d'entrée
├── Views/
│   ├── ContentView.swift           # TabView racine, injection des services
│   ├── Activity/
│   │   ├── StepRingView.swift      # Anneau de progression + pas du jour
│   │   ├── DayNavigationView.swift # Chevrons + sélecteur de jour
│   │   └── WeeklyChartView.swift   # Courbe linéaire semaine en cours vs précédente
│   ├── Calendar/
│   │   └── MonthCalendarView.swift # Grille mensuelle des jours
│   ├── Journey/
│   │   ├── JourneyListView.swift   # Liste des 19 trajets par catégorie
│   │   └── JourneyDetailView.swift # Détail d'un trajet + progression
│   ├── Badges/
│   │   └── BadgesView.swift        # Grille badges pas + badges trajets
│   └── Settings/
│       └── SettingsView.swift      # Objectif, couleur, notifications, mode sombre
├── ViewModels/
│   └── StepCountViewModel.swift    # Pas, objectif, streak, badges, couleur anneau
├── Services/
│   └── JourneyProgressService.swift # Progression trajets, distance HK, completion
├── Models/
│   ├── Journey.swift               # Struct Journey + 19 trajets définis
│   ├── JourneyProgress.swift       # Codable : progression km, jalons, completion
│   └── Badge.swift                 # Struct Badge (pas + trajets)
├── Utils/
│   └── AppColors.swift             # ringColorOptions, couleurs présets
└── Resources/
    └── Info.plist
```

> Si tu crées un nouveau fichier, ajoute-le ici avant de committer.

---

## Fonctionnalités implémentées

### Anneau de progression
- Cercle rempli proportionnellement à l'objectif (défaut : 10 000 pas)
- Affiche les pas du jour en cours en temps réel via `HKObserverQuery`
- Couleur personnalisable (picker 6 couleurs, persisté UserDefaults)

#### Couleurs disponibles — `AppColors.ringColorOptions`

| ID | Nom affiché | Hex (approx.) |
|---|---|---|
| `blue` | Bleu | `#007AFF` |
| `green` | Vert | `#34C759` |
| `orange` | Orange | `#FF9500` |
| `pink` | Rose | `#FF2D55` |
| `purple` | Violet | `#AF52DE` |
| `red` | Rouge | `#FF3B30` |

> Toutes les références à la couleur de l'anneau passent par `viewModel.ringColor` — ne jamais hardcoder une couleur dans une View.

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

## Glossaire métier

| Terme | Définition |
|---|---|
| **streak** | Nombre de jours consécutifs où l'objectif de pas a été atteint. Remis à 0 si un jour est manqué. Affiché avec une flamme 🔥, masqué si = 0. |
| **badge (pas)** | Récompense débloquée au franchissement d'un seuil cumulatif de pas (5k, 10k, 25k, 50k, 100k). Non révocable. |
| **badge (trajet)** | Récompense emoji débloquée à la completion d'un trajet. Affiché dans la grille Badges. |
| **journey / trajet** | Itinéraire fictif avec une distance cible. La progression est calculée via `distanceWalkingRunning` depuis la `startDate` d'inscription. |
| **milestone / jalon** | Point kilométrique intermédiaire d'un trajet déclenchant une notification locale. |
| **completion** | État final d'un trajet : 100 % de la distance atteinte. Déclenche badge + notification. Irréversible. |
| **objectif** | Nombre de pas quotidien cible, configurable de 5 000 à 20 000 par l'utilisateur. Défaut : 10 000. |
| **ghost slot** | Élément invisible (`.opacity(0).disabled(true)`) utilisé pour maintenir le centrage d'un composant conditionnel sans décalage de layout. |

---

## Conventions

- **Nommage** : anglais pour le code, commentaires en français si nécessaire
- **Pas de force unwrap** (`!`) — utiliser `guard let` ou `if let`
- **Pas de dépendances externes** — SwiftUI pur uniquement
- **Simulateur** : toujours ajouter `#if targetEnvironment(simulator)` avec des données mock réalistes

### Données mock canoniques (simulateur)

Ne pas inventer des valeurs différentes à chaque session. Utiliser ces constantes comme référence :

```swift
#if targetEnvironment(simulator)
static let mockStepCount: Int = 7_432
static let mockDistanceKm: Double = 5.6
static let mockStreak: Int = 4
static let mockGoal: Int = 10_000
#endif
```

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

### Documentation des Views

- **Views principales** (écrans entiers) : doc `///` sur la struct — ce qu'elle affiche, son ViewModel attendu
- **Sous-views / composants** : doc si le rôle n'est pas évident depuis le nom
- Ne pas documenter `body` — documenter la struct à la place

```swift
/// Affiche l'anneau de progression journalier et le compteur de pas.
/// Reçoit ses données depuis `StepCountViewModel` via `@EnvironmentObject`.
struct StepRingView: View { … }
```

### Previews Xcode

- Utiliser `#Preview` (syntaxe iOS 17+) — pas `PreviewProvider`
- Toujours wrapper avec les `@EnvironmentObject` nécessaires
- Utiliser les données mock canoniques définies ci-dessus

```swift
#Preview {
    StepRingView()
        .environmentObject(StepCountViewModel.preview)
}
```

- Définir une instance statique `preview` sur chaque ViewModel/service avec des données mock injectées.

---

## Patterns à respecter

```swift
// Ghost slot pour maintenir le centrage d'un élément conditionnel
// Utilisé dans : DayNavigationView (chevron droit quand on est sur aujourd'hui)
Color.clear
    .frame(width: 44, height: 44)
    .opacity(0)
    .disabled(true)
```

```swift
// Calcul premier jour du mois (bug connu : toujours tester l'alignement)
// Utilisé dans : MonthCalendarView
let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
```

```swift
// Requête HK idempotente — recalculer depuis startDate, ne jamais incrémenter
// Utilisé dans : JourneyProgressService
let km = await fetchDistance(from: progress.startDate)
guard km > progress.totalKm else { return }
progress.totalKm = km
```

```swift
// Communication entre services — callback plutôt que NotificationCenter
// Câblé dans : ContentView
journeyProgressService.onJourneyCompleted = { id in
    viewModel.markJourneyCompleted(id)
}
```

---

## Workflow Git — collaboration Humain / IA

`main` est toujours stable et déployable. Tout le travail passe par des branches. **L'IA ne pousse jamais directement sur `main` ni sur `dev`.**

### Structure des branches

```
main          ← stable, protégé, mergé uniquement par toi
└── dev       ← branche d'intégration continue
    └── feature/<nom>   ← une branche par feature (créée par l'IA)
    └── fix/<nom>       ← une branche par bugfix (créée par l'IA)
    └── refactor/<nom>  ← une branche par refactoring (créée par l'IA)
```

### Conventions de nommage des branches

```
feature/<nom-court>     # nouvelle fonctionnalité
fix/<nom-court>         # correction de bug
refactor/<nom-court>    # refactoring sans changement fonctionnel
```

Exemples : `feature/journey-detail`, `fix/calendar-alignment`, `refactor/healthkit-service`

### Cycle de travail

```bash
# 1. L'IA crée la branche depuis dev
git checkout dev && git pull origin dev
git checkout -b feature/<nom>

# 2. L'IA développe et committe au fil de l'eau
git add <fichiers>
git commit -m "message"

# 3. L'IA pousse la branche et ouvre une PR feature/<nom> → dev
git push origin feature/<nom>
gh pr create --base dev --title "..." --body "..."

# 4. Toi : tu reviews et merges la PR dans dev

# 5. Toi : quand dev est stable, tu merges dev → main
git checkout main
git merge --no-ff dev -m "Merge dev"
git push origin main
```

### Règles

- L'IA crée toujours une branche depuis `dev`, jamais depuis `main`
- L'IA ouvre une PR vers `dev` — elle ne merge jamais elle-même
- **Toi** tu as le dernier mot : review PR → merge dans `dev` → merge `dev` dans `main`
- Un PR = une feature ou un fix (pas plusieurs)
- Merger avec `--no-ff` pour garder une trace claire dans le log
- Tous les commits de l'IA sont signés `Co-Authored-By: Claude`

---

## Roadmap / Features à venir

### Terminé
- [x] Objectif personnalisable (picker 5 000–20 000 dans les paramètres, persisté UserDefaults)
- [x] Système de trajets avec progression HealthKit distance
- [x] Badges de pas et de trajets
- [x] Streak de jours consécutifs
- [x] Notifications locales (objectif + jalons + completion)
- [x] Couleur de l'anneau personnalisable
- [x] Mode sombre

### Priorité haute — impact utilisateur immédiat
- [ ] **Tests UI** — couverture des vues principales (onboarding, anneau, trajets)
- [ ] **Optimisation HealthKit & météo / mode éco** — réduire les appels en arrière-plan, toggle pour désactiver les requêtes non essentielles
- [ ] **Slide récapitulative hebdomadaire** — affiché le lundi à la première ouverture de la semaine
- [ ] **Widget iOS écran d'accueil** — pas du jour + progression anneau

### Priorité moyenne — enrichissement
- [ ] **Export CSV** — historique de pas et distances exportable
- [ ] **Gamification RPG** — débloquer des actions selon les pas (concept en cours d'évaluation)

### Vision long terme
- [ ] **Développement 100 % IA agentique** — de la rédaction des user stories jusqu'au déploiement : conception des US → développement → tests → publication App Store, piloté par une IA agentique bout en bout

---

## Accessibilité

Conventions VoiceOver et Dynamic Type à respecter sur tous les écrans.

### VoiceOver
- Grouper les éléments liés avec `.accessibilityElement(children: .combine)` — ex : anneau + compteur de pas = un seul élément vocalisé
- Toujours fournir un `.accessibilityLabel` explicite sur les éléments visuels (anneau, icônes SF Symbol, badges)
- Les chevrons de navigation doivent avoir `.accessibilityLabel("Jour précédent")` / `"Jour suivant"`
- Les éléments décoratifs purs reçoivent `.accessibilityHidden(true)`

### Dynamic Type
- Ne jamais hardcoder une taille de police — utiliser les styles système (`.font(.title)`, `.font(.body)`, etc.)
- Pour les textes dans des conteneurs fixes (anneau), tester jusqu'à la taille Accessibilité XXL

### Contraste
- La couleur de l'anneau est personnalisable : s'assurer que le texte superposé (compteur de pas) passe en blanc ou noir selon la luminosité du preset

### Ne pas faire
- Ne pas désactiver `.accessibilityElement` sur un élément interactif
- Ne pas utiliser des couleurs seules pour véhiculer une information (toujours doubler avec un texte ou une icône)

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
