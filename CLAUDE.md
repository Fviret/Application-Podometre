# Pedometer App — CLAUDE.md

<!-- last updated: 2026-07-21 — À mettre à jour à chaque fin de session -->


---

## Contexte de reprise

> **À mettre à jour manuellement avant de clore chaque session Claude Code.**

| Champ | Valeur |
|---|---|
| Branche active | `dev` (PR #53 doc arborescence ouverte ; #47→#52 mergées) |
| Dernière feature travaillée | Refonte des badges (illustration + couleur par badge, titre « Objectif X K », pastille de réussites, modale de détail), flamme de série animée à paliers (`FlameStreakView`), densification des étapes de tous les trajets, accessibilité des Paramètres |
| Fichiers modifiés récemment | `Podomètre/Settings/*` (SettingsView, BadgeData, BadgeGridView, FlameStreakView, StreakBannerView), `Podomètre/Journey/JourneyData.swift`, `Podomètre/Ring/StepCountViewModel.swift` |
| Bugs ouverts connus | Simulateur uniquement : `fetchSteps` (HealthKit) renvoie 0 sur simulateur et écrase le mock lors de la navigation par jour (sans effet sur device) |
| ⚠️ Travail non intégré | 3 changements sont **restés sur des branches distantes, absents de `dev`** : Dynamic Type de la grille de couleurs, retour haptique (couleur/objectif), et regroupement des sections + « À propos ». Présents sur `origin/feature/settings-sections-grouping`. La PR #51 a été mergée avant l'ajout de ces commits, et la PR #52 a été mergée dans la branche `fix/`, pas dans `dev`. → à réappliquer sur `dev`. |
| Prochaine tâche prévue | Réintégrer le travail ci-dessus, puis extraire les récompenses (série + badges) des Paramètres vers un écran dédié ; ensuite : moteur d'histoires (fiction interactive au nombre de pas), widget iOS, récap hebdomadaire |


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

Le projet est organisé **par feature**, pas en couches : chaque dossier regroupe ses Views, son ViewModel/service et ses modèles.

```
Podomètre/
├── Podome_treApp.swift                 # @main, point d'entrée
├── ContentView.swift                   # TabView racine, injection des services
├── AppColors.swift                     # ringColorOptions, couleurs présets
├── PrivacyInfo.xcprivacy               # Manifeste de confidentialité (App Store)
├── Localizable.xcstrings               # String Catalog — langue source française, extraction automatique par le compilateur
├── Ring/                               # Écran Activité (anneau, jour, météo, métriques)
│   ├── StepCountViewModel.swift        # Pas, objectif, streak, badges, métriques du jour
│   ├── StepRingView.swift              # Anneau de progression + navigation par jour
│   ├── RollingNumberText.swift         # Compteur de pas animé
│   ├── TodayMetricsView.swift          # Distance · temps actif · calories
│   ├── MonthCalendarView.swift         # Grille mensuelle des jours
│   ├── WeeklyBarChartView.swift        # Comparaison semaine en cours / précédente ; tap → HistoryDetailView
│   ├── HistoryStats.swift              # Modèle + calcul des statistiques d'historique (tendance, records)
│   ├── HistoryDetailView.swift         # Écran d'historique : tendance multi-semaines, totaux mensuels, records
│   ├── HealthAccessBannerView.swift    # Bannière si accès HealthKit refusé (→ Réglages)
│   ├── LocationManager.swift           # CoreLocation (précision km, pour la météo)
│   ├── WeatherService.swift            # Open-Meteo : horaire + journalier
│   ├── WeatherCache.swift              # Cache position + prévisions, évite un appel réseau si la position n'a pas changé
│   ├── WeatherCode.swift               # Codes WMO → emoji / description
│   ├── WeatherBannerView.swift         # Bannière pluie imminente
│   ├── WeeklyForecastBannerView.swift  # Prévisions 7 jours (tap → détail)
│   └── WeatherDetailView.swift         # Détail météo d'un jour (créneaux horaires)
├── Journey/                            # Trajets
│   ├── JourneyModels.swift             # Journey, Milestone, JourneyProgress
│   ├── JourneyData.swift               # Catalogue des 27 trajets et leurs étapes
│   ├── JourneyProgressService.swift    # Progression, distance HK, completion
│   ├── JourneyNotificationService.swift# Notifications jalons + completion
│   ├── ActiveJourneyCardView.swift     # Card du trajet en cours (progression + ETA), en tête du catalogue
│   ├── StartJourneyPromptCardView.swift# Card d'incitation au démarrage (aucun trajet en cours), même gabarit
│   ├── JourneySegmentTrackView.swift   # Tracé du segment courant (jalon → jalon, « tu es ici »), partagé card + détail
│   ├── JourneyPickerView.swift         # Catalogue par catégorie
│   ├── JourneyPreviewSheet.swift       # Prévisualisation avant démarrage
│   └── JourneyDetailView.swift         # Détail d'un trajet + timeline des jalons
├── Settings/                           # Paramètres et récompenses
│   ├── SettingsView.swift              # Objectif, apparence, écran principal, notifs
│   ├── MainScreenSection.swift         # Sections optionnelles de l'écran Activité, ordre réorganisable
│   ├── BadgeData.swift                 # Seuils/illustration des badges de pas (données uniquement, plus affiché en UI)
│   ├── StreakBannerView.swift          # Bannière de série
│   └── FlameStreakView.swift           # Flamme animée à paliers (série)
├── Aphorism/                           # Pensée du jour
│   ├── AphorismModels.swift            # Aphorism, AphorismData (Codable)
│   ├── AphorismManager.swift           # Sélection déterministe + garde 1×/jour
│   ├── AphorismPopupView.swift         # Popup matinale
│   ├── AphorismCardView.swift          # Carte de l'aphorisme
│   ├── AphorismSettingsView.swift      # Section Paramètres
│   ├── aphorisms_humor_400.json        # Recueil français (400 aphorismes, CC0)
│   └── aphorisms_humor_en.json         # Recueil anglais (89 aphorismes, domaine public — Wilde/Bierce/Twain/Franklin)
├── WeeklyRecap/                        # Récapitulatif hebdomadaire
│   ├── WeeklyRecapData.swift           # Modèle (totaux + comparaison semaine précédente) et enum de tendance
│   └── WeeklyRecapView.swift           # Sheet affichée le lundi à la première ouverture de la semaine
├── Preferences/                        # Persistance UserDefaults centralisée
│   ├── PreferenceKey.swift             # Enum de toutes les clés
│   ├── Preferences.swift               # Wrapper typé, injectable pour les tests
│   └── AppStorage+PreferenceKey.swift  # Extension @AppStorage(.maClé)
└── Views/
    └── Onboarding/
        ├── OnboardingView.swift        # 4 slides, premier lancement
        └── OnboardingGoals.swift       # Catalogue des objectifs proposés
```

Hors cible applicative, à la racine du dépôt :

```
├── Podome-tre-Info.plist               # Info.plist du projet
├── PodomètreTests/                     # Tests unitaires (Swift Testing)
├── PodomètreUITests/                   # Tests UI (XCUITest)
└── .github/workflows/ios.yml           # CI : build de vérification sur les PR
```

> Si tu crées un nouveau fichier, ajoute-le ici avant de committer.
>
> **Convention** : un nouveau fichier va dans le dossier de sa feature (`Ring/`, `Journey/`, `Settings/`, `Aphorism/`…). Ne pas recréer de découpage en couches (`Views/`, `ViewModels/`, `Models/`).
>
> ⚠️ `Views/Onboarding/` est le seul reliquat de l'ancienne convention `Views/` ; à déplacer vers `Onboarding/` lors d'un prochain passage.

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
- Pastille de tendance de la moyenne quotidienne (rouge/neutre/couleur anneau vs semaine précédente)
- Tap sur le graphe → `HistoryDetailView` : tendance sur 10 semaines (semaines tappables, intervalle de dates, tendance vs semaine précédente), totaux mensuels par année civile (janvier à décembre, swipe pour changer d'année aussi loin que l'historique disponible, mois futurs grisés à hauteur de la moyenne de l'année), plus longue série mise en avant (`FlameStreakView`, réutilisée depuis Settings), records personnels (meilleur jour/semaine/année, semaines et mois parfaits — masqués si 0), cumul total de pas. Calcul à la demande sur tout l'historique HealthKit (`StepCountViewModel.fetchHistoryStats()`), non persisté.

### Paramètres
- Objectif quotidien : picker 5 000–20 000 pas
- Couleur de l'anneau : 6 presets (`AppColors.ringColorOptions`), propagée partout
- Notifications : toggle objectif journalier (1x/jour max)
- Mode sombre : toggle, appliqué via `.preferredColorScheme` sur le `TabView`
- Streak : série de jours consécutifs (flamme 🔥), cachée si streak = 0
- Écran principal : toggle d'affichage par section (métriques, météo, calendrier, graphe) + réordonnancement par glisser-déposer (liste `.onMove`, appui long sur une ligne) ; l'ordre choisi pilote directement l'ordre de rendu sous l'anneau sur l'écran Activité
- Plus de grille de badges dans les Paramètres : les badges de trajets vivent désormais sur l'écran Trajets (voir ci-dessous) ; les badges de seuils de pas n'ont plus d'écran (données conservées dans `BadgeData`/`StepCountViewModel.milestoneCounts`, réutilisables pour une future UI)

### Récapitulatif hebdomadaire
- Sheet affichée le lundi à la première ouverture de la semaine (garde 1×/semaine, `lastWeeklyRecapShownWeekStart`)
- Bilan de la semaine calendaire écoulée (lundi → dimanche) : nombre de jours où l'objectif a été atteint, puis pas / calories / distance / temps d'activité, chacun avec une flèche de tendance vs la semaine précédente (même convention que `WeeklyBarChartView` : rouge en baisse, couleur de l'anneau en hausse, gris stable)
- Récupération HealthKit + Core Motion dédiée (`StepCountViewModel.fetchWeeklyRecapData`), indépendante de `HistoryStats` (blocs calendaires lundi-dimanche, pas des fenêtres glissantes de 7 jours)

### Système de trajets
- 27 trajets dans 4 catégories : Promenades, Sentiers, Histoire, Mythes & Épopées
- Progression via `distanceWalkingRunning` depuis `startDate` (requête idempotente)
- `HKObserverQuery` live sur la distance — mise à jour sans ouvrir la vue
- Jalons (milestones) débloqués au fil du km, avec notification locale
- Catégories repliables (accordéon) dans le catalogue ; compteur = trajets restants (non terminés)
- Trajets terminés : grille de badges compacts (emoji + nom) en tête de chaque catégorie ; tap → popup avec date de complétion (`journeyCompletionDates`)
- Completion : badge débloqué + notification + popup de détail (pas de navigation vers l'écran de détail, qui dépend de la progression en cours — supprimée à la complétion)

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
| `journeyCompletionDates` | `Data` (JSON) | `[String: Date]` — date de complétion par UUID de trajet |
| `journeyProgressMap` | `Data` (JSON) | `[UUID: JourneyProgress]` encodé |
| `aphorismPopupEnabled` | `Bool` | Toggle pensée du jour (défaut : activé) |
| `lastAphorismDisplayDate` | `Date` | Garde pour max 1 popup pensée du jour/jour |
| `showWeatherForecast` | `Bool` | Affiche météo/prévisions sur l'écran principal (défaut : activé) |
| `showMonthCalendar` | `Bool` | Affiche le calendrier mensuel (défaut : activé) |
| `showWeeklyChart` | `Bool` | Affiche le graphe hebdomadaire (défaut : activé) |
| `showTodayMetrics` | `Bool` | Affiche les métriques du jour (distance/temps actif/calories) (défaut : activé) |
| `mainScreenSectionOrder` | `Data` (JSON) | `[MainScreenSection]` encodé — ordre d'affichage des sections sous l'anneau (réorganisable dans Paramètres, glisser-déposer) |
| `weatherCache` | `Data` (JSON) | `WeatherCache` encodé — dernière position + prévisions récupérées ; évite un appel météo si la position n'a pas changé depuis le dernier lancement |
| `lastWeeklyRecapShownWeekStart` | `Date` | Lundi de la semaine pour laquelle le récapitulatif hebdomadaire a déjà été affiché (garde 1×/semaine) |

Ne pas créer de nouvelles clés sans les ajouter ici.

> **Centralisation** : toutes les clés sont définies dans l'enum `PreferenceKey` (`Podomètre/Preferences/PreferenceKey.swift`). Ne jamais écrire une chaîne de clé en dur.
> - Dans les Views : `@AppStorage(.isDarkMode)` (extension `AppStorage(_:)` typée).
> - Dans les ViewModels/services : le wrapper `Preferences` (`Preferences.shared.set(_, for:)` / `.bool(_)`), injectable via `Preferences(defaults:)` pour les tests.
> - `rawValue` d'un `case` = chaîne historique exacte : ne jamais renommer un `case` sans migration.

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
- [x] Pensée du jour — popup matinale + carte dans les Paramètres (recueil de 400 aphorismes CC0) + rappel notification de midi si l'app n'a pas encore été ouverte

### Priorité haute — impact utilisateur immédiat
- [x] **Tests UI** — couverture des vues principales (onboarding, anneau, trajets, pensée du jour)
- [ ] **Optimisation HealthKit & météo / mode éco** — réduire les appels en arrière-plan, toggle pour désactiver les requêtes non essentielles
- [x] **Slide récapitulative hebdomadaire** — affichée le lundi à la première ouverture de la semaine
- [ ] **Widget iOS écran d'accueil** — pas du jour + progression anneau

### Priorité moyenne — enrichissement
- [ ] **Pensée du jour** — améliorations : animation d'apparition, bouton de partage
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

## Localisation

Infrastructure posée (`Localizable.xcstrings`, langue source française), **traduction pas encore commencée**.

- Convention **source-as-key** : on continue d'écrire les `Text("...")` directement en français, sans clé symbolique. Le compilateur Swift extrait automatiquement chaque chaîne dans le String Catalog à la compilation (`SWIFT_EMIT_LOC_STRINGS = YES` sur la cible principale) — aucune friction au quotidien, pas d'étape manuelle.
- Le français reste la langue source (`developmentRegion = fr`) ; l'anglais n'est pas encore ajouté comme langue cible dans le catalogue.
- **Prochaines étapes** (dans l'ordre) :
  1. ~~Migration technique (String Catalog, zéro traduction)~~ ✅
  2. ~~Traduction du contenu hors pensée du jour~~ ✅ — 693 chaînes dans `Localizable.xcstrings` : les 28 trajets (505) + l'interface (188, dont 175 chaînes UI et 13 variantes capitalisées pour la météo). Chaque chaîne dérivée d'une variable (pas d'un littéral `Text("...")`) — labels de trajets, records de l'historique, catégories, couleur d'anneau, météo, date sélectionnée — a été enveloppée dans `Text(LocalizedStringKey(...))` à son point d'affichage pour forcer la recherche dans le catalogue au runtime.
     - **Bug trouvé au passage** : l'en-tête de catégorie (`JourneyPickerView`) appelait `.uppercased()` sur `category.rawValue` *avant* la recherche de traduction, cherchant la clé `"PROMENADES"` au lieu de `"Promenades"` (jamais trouvée). Corrigé en gardant la casse d'origine pour la recherche et en appliquant `.textCase(.uppercase)` côté affichage.
     - **Limite non résolue** : les phrases composées (gabarit + valeur interpolés dans un même `Text("... \(x) ...")`, ex. « Prochaine étape : **X** dans Y km ») ne sont pas couvertes — la partie fixe se traduira une fois extraite par un vrai build Xcode, mais la valeur insérée resterait en français. De même, la date du jour sélectionné (hors "Aujourd'hui"/"Hier") reste formatée en français (`DateFormatter` figé sur `Locale(identifier: "fr_FR")` dans `StepRingView`/`ActiveJourneyCardView`) — nécessiterait de passer sur la locale de l'appareil.
  3. Recherche d'un recueil d'aphorismes équivalent en anglais (domaine public/CC0) — ne pas traduire le recueil français, l'humour et la licence ne survivent pas à la traduction
  4. Intégration du contenu « pensée du jour » anglais pour les appareils en anglais
- Ne pas traduire avant que le catalogue de contenu (trajets, jalons) soit stabilisé, sous peine de retraduire en boucle à chaque ajout.
- **Mécanisme pour le contenu des trajets** (`JourneyData.swift`) : les chaînes y sont des *données*, pas des littéraux `Text("...")` — le compilateur ne les extrait donc pas automatiquement. Les vues qui les affichent utilisent `Text(LocalizedStringKey(journey.name))` (au lieu de `Text(journey.name)`) pour forcer une recherche dans le String Catalog au runtime ; les traductions sont ajoutées à la main dans `Localizable.xcstrings`, avec le texte français exact comme clé. **Limite connue** : les phrases composées (ex. « Prochaine étape : **X** dans Y km ») et les libellés d'accessibilité/notifications ne sont pas encore couverts par ce mécanisme — la partie fixe du gabarit se traduit, mais le nom du jalon inséré reste en français dans ces phrases précises.

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
NSMotionUsageDescription   # Core Motion (CMPedometer) — pas en quasi temps réel
```

> Les clés d'usage sont générées via `INFOPLIST_KEY_*` dans le projet (`GENERATE_INFOPLIST_FILE = YES`), pas dans un fichier Info.plist.

Types HK lus : `stepCount`, `distanceWalkingRunning`

**Pas en temps réel** : au premier plan et pour aujourd'hui, `StepCountViewModel` affiche les pas via `CMPedometer` (Core Motion, mise à jour ~1×/s en marchant). HealthKit reste la source de vérité (historique, streak, arrière-plan). Voir `startLiveStepUpdates()` / `stopLiveStepUpdates()`.

Capacité HealthKit activée dans les entitlements du projet.
