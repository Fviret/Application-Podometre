# Podomètre

Application iOS de suivi de pas quotidiens, développée en Swift/SwiftUI pur, sans dépendances tierces.


---

## Aperçu

📷

---

## Fonctionnalités

- Anneau de progression en temps réel connecté à HealthKit
- Navigation entre les jours, calendrier mensuel et graphe hebdomadaire
- Bannière pluie imminente + prévisions météo 7 jours (Open-Meteo, sans clé API)
- Système de trajets avec progression sur distance réelle (walking + running)
- Badges de pas et de trajets débloqués selon les performances
- Streak de jours consécutifs où l'objectif est atteint
- Notifications locales : objectif journalier et jalons de trajet (toggles indépendants)
- Personnalisation : couleur de l'anneau, objectif quotidien, mode sombre, sections de l'écran principal

---

## Écrans

### Activité

L'écran principal de l'app.

📷

**Anneau de progression**
Affiche les pas du jour sous forme d'un arc coloré, rempli proportionnellement à l'objectif quotidien. La couleur de l'anneau est personnalisable dans les Paramètres.

**Navigation par jour**
Les chevrons gauche/droit permettent de consulter n'importe quel jour passé. Le label central affiche "Aujourd'hui", "Hier", ou la date courte.

📷

**Bannière pluie**
Affichée en haut de l'écran si la localisation est autorisée. Indique uniquement en cas de pluie imminente :

- Invisible si la localisation est refusée ou aucune pluie attendue
- *"Pluie en cours"* — précipitations actuelles détectées
- *"Pluie dans moins d'1h"* — pluie prévue dans l'heure suivante

Se rafraîchit toutes les 30 minutes. Masquée silencieusement en cas d'erreur réseau.

📷

**Prévisions 7 jours**
Scroll horizontal sous l'anneau affichant aujourd'hui et les 6 jours suivants : emoji météo WMO, températures min/max, précipitations si > 0,2 mm. Le jour actuel est mis en évidence. La ville est affichée en dessous via reverse geocoding.

📷

**Calendrier mensuel**
Grille des jours du mois en cours. Chaque jour est représenté par un cercle :
- Cercle plein coloré → objectif atteint
- Cercle vide coloré → pas enregistrés, objectif non atteint
- Cercle gris → aucune donnée

Un tap sur un jour le sélectionne et met à jour l'anneau.

📷

**Graphe hebdomadaire**
Courbe des 7 derniers jours (semaine en cours en couleur, semaine précédente en gris). Une ligne pointillée indique la moyenne de la semaine en cours.

📷

---

### Trajets

Catalogue de 19 trajets organisés en 4 catégories.

📷

**Catégories disponibles**

| Catégorie | Description |
|---|---|
| 🌿 Promenades | Courtes distances (2,5 km → 42 km) |
| 🏔️ Sentiers | Grands sentiers européens (GR20, Camino, TMB…) |
| 👑 Histoire | Routes historiques (Route de la Soie, Alexandre…) |
| 🔱 Mythes & Épopées | Trajets mythologiques (Odyssée, Iliade…) |

**États d'un trajet**

Chaque carte de trajet a trois états :

- **Disponible** — bouton "Voir le trajet" ouvre la prévisualisation des étapes
- **En cours** — barre de progression en km réels + "Voir mes étapes"
- **Terminé** — checkmark coloré, carte légèrement grisée

📷

**Prévisualisation**
Avant de démarrer, une sheet liste toutes les étapes du trajet avec leur description. Le bouton "Commencer le trajet" démarre la progression depuis aujourd'hui.

📷

**Détail du trajet**
Vue complète avec barre de progression globale, prochaine étape à atteindre, et timeline de tous les jalons. Les jalons débloqués sont cliquables pour lire leur description.

📷

Quand le trajet est terminé, un bandeau "Vous avez achevé ce trajet !" remplace la prochaine étape.

📷

**Progression**
La distance est lue depuis HealthKit (`distanceWalkingRunning`) depuis la date de démarrage du trajet. La mise à jour est automatique, en temps réel, via un observer HealthKit — sans avoir besoin d'ouvrir la vue.

---

### Paramètres

📷

**Objectif quotidien**
Picker de 5 000 à 20 000 pas (par paliers de 500). L'objectif est persisté et utilisé partout dans l'app (anneau, calendrier, streak, notifications).

**Personnalisation des couleurs**
6 couleurs disponibles pour l'anneau de progression. La couleur sélectionnée se propage à l'ensemble de l'app : anneau, calendrier, graphe, badges, trajets.

| Couleur | Nom |
|---|---|
| 🟢 | Forêt |
| 🔵 | Océan |
| 🟡 | Soleil |
| 🔴 | Corail |
| 🟣 | Violet |
| 🩵 | Glace |

📷

**Mon écran principal**
Trois toggles pour afficher ou masquer des sections de l'écran Activité :

- *Météo & prévisions* — bannière pluie + prévisions 7 jours (désactiver coupe aussi les appels réseau et la localisation)
- *Calendrier mensuel* — grille du mois en cours
- *Graphe hebdomadaire* — courbe de comparaison semaine en cours / précédente

**Notifications**
- *Objectif journalier* — notification locale dès que le compteur franchit l'objectif. Maximum une fois par jour.
- *Progression des trajets* — notifications aux jalons kilométriques et à la completion d'un trajet. Toggle indépendant de l'objectif journalier.
- *Mode sombre* — bascule toute l'app en thème sombre, indépendamment du réglage système.

**Streak 🔥**
Nombre de jours consécutifs où l'objectif a été atteint, affiché uniquement quand la série est active (≥ 1 jour). Calculé via HealthKit en remontant jour par jour depuis aujourd'hui.

📷

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

📷

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

## Installation

1. Cloner le repo
2. Ouvrir `Podomètre.xcodeproj` dans Xcode
3. Sélectionner un device ou simulateur iOS 17+
4. Lancer (`⌘R`)

> HealthKit requiert un device physique pour les données réelles. Le simulateur injecte des données fictives.
