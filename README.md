# Podomètre

Podomètre transforme vos pas quotidiens en voyage. Chaque kilomètre parcouru vous rapproche d'une destination réelle — le GR20, Compostelle, la Route de la Soie ou l'Odyssée d'Ulysse.

---

## Aperçu

<p align="center">
  <img width="150" alt="IMG_5084" src="https://github.com/user-attachments/assets/896263e2-35bc-49e6-85ef-2016d04ad9d7" />
  <img width="150" alt="IMG_5085" src="https://github.com/user-attachments/assets/4dc30dae-8341-475a-a802-a5ea3205b414" />
  <img width="150" alt="IMG_5090" src="https://github.com/user-attachments/assets/d86a0c87-9d03-477a-a464-7f025ec8b281" />
  <img width="150" alt="IMG_5087" src="https://github.com/user-attachments/assets/00a04998-4738-4bda-88fd-f80ea15a0894" />
  <img width="150" alt="IMG_5086" src="https://github.com/user-attachments/assets/ec6045cc-5024-469e-bdd8-e92510530198" />
</p>

---

## Fonctionnalités

- Anneau de progression en temps réel connecté à HealthKit, avec halo de célébration et pourcentage d'objectif à l'atteinte
- Navigation entre les jours par chevrons **ou par swipe sur l'anneau**, calendrier mensuel et graphe hebdomadaire
- Métriques du jour sous l'anneau : distance, temps actif (Core Motion) et calories, suivant le jour sélectionné
- Bannière pluie imminente + prévisions météo 7 jours (Open-Meteo, sans clé API), avec écran de détail au tap sur un jour
- Système de trajets avec progression sur distance réelle (walking + running), et **card du trajet en cours épinglée** (progression jusqu'à la prochaine étape + date d'arrivée estimée)
- Badges de pas et de trajets débloqués selon les performances
- Série de jours consécutifs, matérialisée par une **flamme animée à paliers de couleur**
- Notifications locales : objectif journalier et jalons de trajet (toggles indépendants)
- Personnalisation : couleur de l'anneau, objectif quotidien (stepper), mode sombre, sections de l'écran principal
- Pensée du jour : popup matinale (1x/jour) et carte dans les Paramètres — recueil de 400 aphorismes (domaine public CC0)
- Confidentialité : aucune donnée ne quitte l'iPhone ; Privacy Manifest fourni, gestion du refus d'accès HealthKit

---

## Écrans

### Activité

L'écran principal de l'app.
<p align="center">
  <img width="150" alt="IMG_5084" src="https://github.com/user-attachments/assets/bc75d9db-7cca-4ab7-9ccb-29eb87e35550" />
</p>

**Anneau de progression**
Affiche les pas du jour sous forme d'un arc coloré, rempli proportionnellement à l'objectif quotidien. La couleur de l'anneau est personnalisable dans les Paramètres. Le centre affiche le compteur de pas, le pourcentage d'objectif atteint (non plafonné) et, dès l'objectif franchi aujourd'hui, la série 🔥 et un halo de célébration animé (respecte « Réduire les animations »).

**Métriques du jour**
Sous l'anneau, trois tuiles résument le jour sélectionné : distance parcourue (km), temps actif et calories. Le temps actif est calculé via Core Motion (segments marche / course / vélo), ce qui fonctionne sur iPhone seul sans Apple Watch. La ligne suit le jour choisi via les chevrons et se masque depuis les Paramètres.

**Navigation par jour**
Les chevrons gauche/droit — ou un **swipe horizontal sur l'anneau** — permettent de consulter n'importe quel jour passé (jamais dans le futur). Le label central affiche "Aujourd'hui", "Hier", ou la date courte.
<p align="center">
<img width="500" alt="IMG_5091" src="https://github.com/user-attachments/assets/8b405308-47cd-40c8-a855-50dd0952b72c" />
</p>

**Accès HealthKit refusé**
Si l'app ne reçoit aucun pas alors que l'autorisation a déjà été demandée (accès refusé), une bannière non bloquante explique la situation et propose d'ouvrir les Réglages. L'app reste utilisable (trajets, pensée du jour) sans les données de santé.


**Bannière pluie**
Affichée en haut de l'écran si la localisation est autorisée. Indique uniquement en cas de pluie imminente :

- Invisible si la localisation est refusée ou aucune pluie attendue
- *"Pluie en cours"* — précipitations actuelles détectées
- *"Pluie dans moins d'1h"* — pluie prévue dans l'heure suivante

Se rafraîchit toutes les 30 minutes. Masquée silencieusement en cas d'erreur réseau.

<p align="center">
  <img width="500" alt="IMG_5093" src="https://github.com/user-attachments/assets/b1599576-51da-4a77-899b-a653a4c08e9a" />
</p>

**Prévisions 7 jours**
Scroll horizontal sous l'anneau affichant aujourd'hui et les 6 jours suivants : emoji météo WMO, températures min/max, précipitations si > 0,2 mm. Le jour actuel est mis en évidence. La ville est affichée en dessous via reverse geocoding.

Un tap sur un jour ouvre un **écran de détail météo** : condition et emoji, max/min, précipitations et localisation, alerte pluie (pour aujourd'hui), et une liste compacte des prévisions du jour par créneaux horaires (00 h–02 h … 22 h–00 h). Les données horaires couvrent les 7 jours (Open-Meteo, sans clé), parsées en heure locale.

<p align="center">
  <img width="500" alt="IMG_5094" src="https://github.com/user-attachments/assets/2444aabb-127b-4565-a50a-c9b990993dca" />
</p>

**Calendrier mensuel**
Grille des jours du mois en cours. Chaque jour est représenté par un cercle :
- Cercle plein coloré → objectif atteint
- Cercle vide coloré → pas enregistrés, objectif non atteint
- Cercle gris → aucune donnée

Un tap sur un jour le sélectionne et met à jour l'anneau.

<p align="center">
  <img width="500" alt="IMG_5095" src="https://github.com/user-attachments/assets/a92f2316-5c09-4d8f-8485-2e20e6be0369" />
</p>


**Graphe hebdomadaire**
Courbe des 7 derniers jours (semaine en cours en couleur, semaine précédente en gris). Une ligne pointillée indique la moyenne de la semaine en cours.

<p align="center">
  <img width="500" alt="IMG_5097" src="https://github.com/user-attachments/assets/e4813b1c-1f99-43b4-b197-19686d1d1145" />
</p>
---

### Trajets

Catalogue de 22 trajets organisés en 4 catégories.

<p align="center">
  <img width="150" alt="IMG_5086" src="https://github.com/user-attachments/assets/246ac810-011f-4dc9-add2-66d95ca52528" />
</p>

**Card du trajet en cours**
Quand un trajet est démarré, il est épinglé en haut de l'écran (et retiré de la liste) : pourcentage global, tracé du segment entre le dernier jalon franchi et le prochain avec un marqueur « tu es ici », distance jusqu'à la prochaine étape, et **date d'arrivée estimée** à partir de la moyenne de pas récente.

**Catégories disponibles**

| Catégorie | Description |
|---|---|
| 🌿 Promenades | Courtes distances (2,5 km → 42 km) |
| 🏔️ Sentiers | Grands sentiers européens (GR20, Camino, TMB…) |
| 👑 Histoire | Routes historiques (Route de la Soie, Alexandre…) |
| 🔱 Mythes & Épopées | Trajets mythologiques (Odyssée, Iliade…) |

Chaque trajet est densément jalonné d'**étapes authentiques** (refuges, villes, batailles, escales mythologiques réels) pour maintenir une récompense régulière.

**États d'un trajet**

Chaque carte de trajet a trois états :

- **Disponible** — bouton "Voir le trajet" ouvre la prévisualisation des étapes
- **En cours** — barre de progression en km réels + "Voir mes étapes"
- **Terminé** — checkmark coloré, carte légèrement grisée

**Prévisualisation**
Avant de démarrer, une sheet liste toutes les étapes du trajet avec leur description. Le bouton "Commencer le trajet" démarre la progression depuis aujourd'hui.

<p align="center">
  <img width="150" alt="IMG_5087" src="https://github.com/user-attachments/assets/3e6582ae-628f-4c7c-8e78-6905603b9b54" />
</p>

**Détail du trajet**
Vue complète avec barre de progression globale, prochaine étape à atteindre, et timeline de tous les jalons. Les jalons débloqués sont cliquables pour lire leur description.

<p align="center">
  <img width="150" alt="IMG_5102" src="https://github.com/user-attachments/assets/a3f0206d-a33c-4ce6-82af-337bb8eeaddf" />
</p>

Quand le trajet est terminé, un bandeau "Vous avez achevé ce trajet !" remplace la prochaine étape.

**Progression**
La distance est lue depuis HealthKit (`distanceWalkingRunning`) depuis la date de démarrage du trajet. La mise à jour est automatique, en temps réel, via un observer HealthKit — sans avoir besoin d'ouvrir la vue.

---

### Paramètres

<p align="center">
  <img width="150" alt="IMG_5090" src="https://github.com/user-attachments/assets/12a5ab07-084f-4724-9ef7-92ad91e8fa16" />

</p>

Les sections sont regroupées par intention : **Mon objectif · Apparence · Écran principal · Notifications · Pensée du jour · Récompenses · À propos**.

**Mon objectif**
Stepper − / + par paliers de 500 pas, de 500 à 100 000 (appui long pour un défilement accéléré, léger rebond de la valeur à chaque changement). L'objectif est persisté et utilisé partout dans l'app (anneau, calendrier, série, notifications).

**Personnalisation des couleurs** *(section Apparence)*
6 couleurs disponibles pour l'anneau de progression. La couleur sélectionnée se propage à l'ensemble de l'app : anneau, calendrier, graphe, badges, trajets.

| Couleur | Nom |
|---|---|
| 🟢 | Forêt |
| 🔵 | Océan |
| 🟡 | Soleil |
| 🔴 | Corail |
| 🟣 | Violet |
| 🩵 | Glace |
- *Mode sombre* — bascule toute l'app en thème sombre, indépendamment du réglage système.

<p align="center">
<img width="500" alt="IMG_5099" src="https://github.com/user-attachments/assets/d8fee14f-2ba9-434f-8564-9a9d0798f8a5" />
</p>

**Mon écran principal**
Quatre toggles pour afficher ou masquer des sections de l'écran Activité :

- *Météo & prévisions* — bannière pluie + prévisions 7 jours (désactiver coupe aussi les appels réseau et la localisation)
- *Métriques du jour* — distance · temps actif · calories sous l'anneau
- *Calendrier mensuel* — grille du mois en cours
- *Graphe hebdomadaire* — courbe de comparaison semaine en cours / précédente

**Notifications**
- *Objectif journalier* — notification locale dès que le compteur franchit l'objectif. Maximum une fois par jour.
- *Progression des trajets* — notifications aux jalons kilométriques et à la completion d'un trajet. Toggle indépendant de l'objectif journalier.


**Série (récompenses)**
Nombre de jours consécutifs où l'objectif a été atteint, affiché uniquement quand la série est active (≥ 1 jour). Calculé via HealthKit en remontant depuis aujourd'hui — indépendant du jour consulté à l'écran. Matérialisée par une **flamme animée** dont la couleur et le nombre de couches évoluent avec la série (braise grise → orange → rouge → vert → bleu à 21 jours), figée si « Réduire les animations » est actif.

À propos : version de l'app, source des données, mention de confidentialité et licence CC0 du recueil d'aphorismes ; bouton « Revoir la présentation » pour relancer l'onboarding.

**Badges**

Deux types de badges :

*Badges de pas* — 6 seuils quotidiens. Le compteur indique combien de fois ce seuil a été atteint dans toute l'historique HealthKit. Un tap affiche le détail.

| Badge | Seuil |
|---|---|
| 5 000 pas | Première catégorie |
| 10 000 pas | Objectif classique |
| 20 000 pas | Actif |
| 30 000 pas | Très actif |
| 50 000 pas | Exceptionnel |
| 100 000 pas | Légendaire |

*Badges de trajets* — un emoji par trajet du catalogue. Grisé jusqu'à la completion du trajet, coloré avec glow une fois terminé.

<p align="center">
  <img width="500" alt="IMG_5101" src="https://github.com/user-attachments/assets/bfe44fb2-0dee-4333-ac36-cf24dbec4f4a" />
</p>

---

## Accessibilité

Un audit statique a été réalisé sur l'ensemble des vues Swift (8 fichiers) : revue du code, vérification des attributs dans Xcode Accessibility Inspector sur simulateur. **Aucun test VoiceOver bout-en-bout sur device physique n'a encore été réalisé** — c'est l'étape suivante avant de considérer l'accessibilité comme validée.

Ce qui a été appliqué :

- **VoiceOver** — tous les éléments custom ont un `accessibilityLabel` et `accessibilityValue` explicites. Les ZStack composites (anneau, cellules calendrier, jalons, badges, météo) sont regroupés en un seul élément sémantique. Le graphe hebdomadaire est lu comme un résumé textuel complet. Les icônes décoratives sont masquées avec `.accessibilityHidden(true)`.
- **Dynamic Type** — toutes les tailles de police fixes remplacées par des styles système (`headline`, `subheadline`, `callout`, `caption`, etc.) pour s'adapter aux préférences de taille de texte.
- **Reduce Motion** — toutes les animations conditionnées par `@Environment(\.accessibilityReduceMotion)` et désactivées si l'utilisateur a activé "Réduire les animations" dans les réglages iOS.

> Pour tester VoiceOver : Réglages → Accessibilité → VoiceOver, ou triple-clic sur le bouton latéral si le raccourci est configuré.

---

## Onboarding

Affiché au premier lancement, avant l'écran principal. Navigable par swipe ou bouton "Suivant".

| Slide | Contenu |
|---|---|
| 1 — Activité | Screenshot de l'anneau de progression avec légende |
| 2 — Trajets | Screenshot de l'écran trajets avec légende |
| 3 — HealthKit | Demande d'accès aux données de santé (pas + distance) avec bouton "Plus tard" |
| 4 — Objectif | Sélection de l'objectif quotidien parmi 5 valeurs (5k → 20k), défaut 8 000 pas |

Une fois la slide 4 validée, `hasCompletedOnboarding` passe à `true` dans UserDefaults et l'onboarding ne réapparaît plus. L'onboarding ne peut pas être fermé par swipe.

---

## Stack technique

- **Swift 5.9+** / **SwiftUI** pur (pas de UIKit, pas de Swift Charts)
- **HealthKit** — `stepCount`, `distanceWalkingRunning`, background delivery
- **CoreLocation** — localisation à précision kilomètre pour la météo
- **Open-Meteo API** — prévisions météo gratuites, sans clé (hourly + daily)
- **UserNotifications** — notifications locales événementielles
- **UserDefaults** — persistence légère (objectif, couleur, badges, trajets, préférences UI)
- **iOS 17+** minimum

## Architecture

MVVM — `ObservableObject` / `@Published`. Deux services principaux :
- `StepCountViewModel` — pas, objectif, streak, badges, couleur
- `JourneyProgressService` — trajets, distance HK, completion, notifications jalons

---

## Tests

Deux niveaux de tests : logique métier (unitaires) et interface utilisateur (UI).

---

### Tests unitaires

**Framework** : Swift Testing (`@Suite` / `@Test` / `#expect`)

**114 tests en 20 suites**

| Suite | Ce qui est testé |
|---|---|
| `Journey.progressPercent` | Calcul du pourcentage de progression (zéro, moitié, 100 %, dépassement) |
| `Journey.nextMilestone` | Prochain jalon à atteindre selon les jalons déjà débloqués |
| `Journey.sortedMilestones` | Tri des jalons par km croissant |
| `Int.asKilometers` | Conversion pas → km (zéro, valeurs standards, valeurs extrêmes) |
| `BadgeData` | Intégrité du catalogue de badges (count, seuils croissants, unicité des IDs) |
| `StepCountViewModel — logique pure` | Progression, labels de date, completion de trajet, couleur d'anneau, notifications |
| `JourneyProgress — Codable` | Round-trip JSON encode/decode |
| `AppColors` | Catalogue de couleurs (non vide, IDs uniques, couleur par défaut présente) |
| `allJourneys catalog` | Intégrité du catalogue de trajets (IDs uniques, totalKm > 0, jalons cohérents) |
| `Onboarding — objectifs` | Catalogue `onboardingGoals` (count, ordre croissant, valeur par défaut, labels non vides) |
| `Onboarding — UserDefaults` | Clé `hasCompletedOnboarding` (valeur par défaut, persistance, réinitialisation) |
| `Aphorism decoding` | Décodage JSON du recueil (champs requis, tolérance aux anciens champs tone/year/source) |
| `AphorismManager.aphorism(forDayOfYear:)` | Sélection déterministe par quantième (premier/dernier jour, wrap, stabilité, recueil vide) |
| `AphorismManager.shouldShowPopup` | Garde 1x/jour (activé par défaut, désactivé, affiché aujourd'hui/hier, recueil vide, mémorisation) |
| `Preferences` | Clés typées : garde-fou anti-renommage, unicité, round-trip, `hasValue`, suppression |
| `WeatherCode` | Mapping code WMO → emoji / description / libellé (conditions, bornes d'intervalle, fallback, casse) |
| `StepCountViewModel — navigation par jour` | Invalidation du compteur au changement de jour, `selectDate`, dates futures ignorées |
| `StepCountViewModel — série` | Série indépendante du jour affiché, jamais négative |
| `StepCountViewModel — progression` | Progression au seuil/fractionnaire, persistance objectif et couleur, repli couleur inconnue |
| `HistoryStats.compute` | Tendance hebdo, meilleure semaine/mois/année, semaines/mois parfaits, plus longue série, jour le plus actif, jours objectif atteint, mois futurs de l'année en cours |

```bash
# Lancer les tests unitaires en CLI
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild test \
  -project "Podomètre.xcodeproj" \
  -scheme "Podomètre" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:PodomètreTests
```

---

### Tests UI

**Framework** : XCUITest — pilotés par variables d'environnement de lancement (`SKIP_ONBOARDING`, `RESET_ONBOARDING`, `RESET_APHORISM`, `DISABLE_APHORISM`).

**22 tests en 5 suites** — couvrent les flux utilisateur principaux sur simulateur.

| Suite | Ce qui est vérifié |
|---|---|
| `OnboardingUITests` | Slides 1→4, boutons de navigation, protection anti-dismiss |
| `TabNavigationUITests` | 3 onglets présents, navigation aller-retour |
| `ActivityUITests` | Anneau visible, label de date, chevrons de navigation |
| `AphorismPopupUITests` | Popup « pensée du jour » : apparition à l'ouverture, fermeture via « Make my day », absence si désactivée |
| `AphorismSettingsUITests` | Section Paramètres : présence du toggle et de la carte de l'aphorisme du jour |

**Isolation des tests** : des variables d'environnement contrôlent l'état UserDefaults au lancement :
- `RESET_ONBOARDING=1` — force l'onboarding (suites onboarding)
- `SKIP_ONBOARDING=1` — bypasse l'onboarding (suites app principale)
- `RESET_APHORISM` / `DISABLE_APHORISM` — contrôlent la popup « pensée du jour »

```bash
# Lancer les tests UI en CLI
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild test \
  -project "Podomètre.xcodeproj" \
  -scheme "Podomètre" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:PodomètreUITests
```

Ou via Xcode : `⌘U`

---

> Les tests unitaires et UI ne couvrent pas les appels HealthKit (requiert un device physique). La logique HealthKit est validée manuellement sur device.

---

## Roadmap

### Terminé
- [x] Anneau de progression en temps réel (HealthKit), halo de célébration + pourcentage d'objectif
- [x] Métriques du jour (distance · temps actif Core Motion · calories)
- [x] Navigation par jour, calendrier mensuel, graphe hebdomadaire
- [x] Bannière météo + prévisions 7 jours (Open-Meteo) + écran de détail météo par jour
- [x] Système de trajets avec progression sur distance réelle + card du trajet en cours (progression + ETA)
- [x] Catalogue densément jalonné (22 trajets, étapes authentiques)
- [x] Badges de pas et de trajets (illustration + couleur par badge, modale de détail)
- [x] Série de jours consécutifs — flamme animée à paliers
- [x] Navigation par jour au swipe sur l'anneau
- [x] Notifications locales (objectif + jalons + completion)
- [x] Personnalisation (couleur anneau, objectif stepper, mode sombre, sections de l'écran principal)
- [x] Onboarding
- [x] Pensée du jour — popup matinale + carte dans les Paramètres (400 aphorismes CC0)
- [x] Accessibilité (VoiceOver, Dynamic Type, « Réduire les animations »)
- [x] Conformité App Store — Privacy Manifest, gestion du refus d'accès HealthKit
- [x] Tests unitaires et UI (Swift Testing + XCUITest)

### Priorité haute — impact utilisateur immédiat
- [ ] **Publication App Store / Play Store**
- [ ] **Classement entre amis** (backend, cross-platform)
- [ ] **Mode éco** — optimisation des appels HealthKit et météo en arrière-plan
- [ ] **Slide récapitulative hebdomadaire** — bilan de la semaine affiché le lundi
- [ ] **Widget iOS** — pas du jour + progression anneau sur l'écran d'accueil

### Priorité moyenne — enrichissement
- [ ] **Pensée du jour** — animation d'apparition, bouton de partage, affichage en notification
- [ ] **Gamification RPG** — débloquer des récompenses selon les pas

### Vision long terme
- [ ] **Développement 100 % IA agentique** — de la rédaction des user stories jusqu'au déploiement App Store, piloté par une IA agentique bout en bout : US → dev → tests → publication
