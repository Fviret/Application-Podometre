import Foundation

/// Catalogue de tous les trajets disponibles, regroupables par catégorie.
let allJourneys: [Journey] = [
    // Promenades
    journeyWalk2k5,
    journeyWalk5k,
    journeyWalk10k,
    journeyWalk21k,
    journeyWalk42k,
    journeyAmeliePoulain,
    journeyBeforeSunrise,
    journeyNottingHill,
    journeyRocky,
    journeyLostInTranslation,
    // Sentiers
    journeyGR20,
    journeyCaminoFinal,
    journeyCaminoComplet,
    journeyViaPlata,
    journeyTMB,
    journeyViaFrancigena,
    journeySentierDouaniers,
    journeyStevenson,
    journeyGR20Nord,
    // Histoire
    journeyRouteRoyalePerse,
    journeyAlexandrePerse,
    journeyAlexandreComplet,
    journeyRouteSoie,
    journeyMarcoPolo,
    journeyHannibal,
    // Mythes & Épopées
    journeyOdysseeReel,
    journeyOdysseeComplet,
    journeyIliade,
]

// MARK: - Promenades

private let journeyWalk2k5 = Journey(
    id: UUID(uuidString: "F6A7B8C9-0001-0001-0001-000000000001")!,
    name: "Tour des Tuileries",
    subtitle: "Du Louvre à la Concorde — 2,5 km",
    totalKm: 2.5,
    category: .walk,
    emoji: "🌿",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0001-0001-0001-000000000011")!,
            km: 0,
            label: "Pyramide du Louvre",
            description: "Départ face à la pyramide de verre. Les cours du palais s'ouvrent sur un des musées les plus visités au monde."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0001-0001-0001-000000000012")!,
            km: 1.2,
            label: "Bassin octogonal",
            description: "Centre géométrique du jardin. Les chaises vertes, les enfants aux voiliers, le soleil sur l'eau — Paris au ralenti."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0001-0001-0001-000000000013")!,
            km: 2.5,
            label: "Place de la Concorde",
            description: "L'obélisque de Louxor marque l'arrivée. La plus grande place de Paris s'ouvre sur les Champs-Élysées à l'ouest."
        ),
    ]
)

private let journeyWalk5k = Journey(
    id: UUID(uuidString: "F6A7B8C9-0002-0002-0002-000000000002")!,
    name: "Berges de la Seine",
    subtitle: "Notre-Dame → Tour Eiffel — 5 km",
    totalKm: 5,
    category: .walk,
    emoji: "🌊",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0002-0002-0002-000000000021")!,
            km: 0,
            label: "Notre-Dame de Paris",
            description: "Départ face au parvis de la cathédrale, sur l'Île de la Cité. La Seine coule de chaque côté."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0002-0002-0002-000000000022")!,
            km: 2,
            label: "Pont des Arts",
            description: "Le pont piéton aux anciens cadenas d'amour. Vue dégagée sur l'Institut de France et le Louvre."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0002-0002-0002-000000000023")!,
            km: 5,
            label: "Tour Eiffel",
            description: "La dame de fer vue depuis le Champ-de-Mars. Depuis les berges, elle apparaît d'un coup au détour du pont de l'Alma."
        ),
    ]
)

private let journeyWalk10k = Journey(
    id: UUID(uuidString: "F6A7B8C9-0003-0003-0003-000000000003")!,
    name: "Boucle de Central Park",
    subtitle: "Le grand tour du parc new-yorkais — 10 km",
    totalKm: 10,
    category: .walk,
    emoji: "🍂",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0003-0003-0003-000000000031")!,
            km: 0,
            label: "Grand Army Plaza",
            description: "Entrée sud du parc, à deux pas du Plaza Hotel. Les calèches attendent, les gratte-ciel de Midtown encadrent les premiers arbres."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0003-0003-0003-000000000032")!,
            km: 3,
            label: "Bethesda Fountain",
            description: "La fontaine de l'Ange des Eaux, cœur romantique du parc. Les terrasses donnent sur le lac et ses barques."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0003-0003-0003-000000000033")!,
            km: 6,
            label: "Harlem Meer",
            description: "Lac tranquille à l'angle nord-est, loin de l'agitation touristique. Les colverts y hivernent, les New-Yorkais y pêchent."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0003-0003-0003-000000000034")!,
            km: 10,
            label: "Strawberry Fields",
            description: "Mosaïque « Imagine » en hommage à John Lennon, qui habitait le Dakota Building juste en face. Bouclage du tour."
        ),
    ]
)

private let journeyWalk21k = Journey(
    id: UUID(uuidString: "F6A7B8C9-0004-0004-0004-000000000004")!,
    name: "Semi-marathon de Paris",
    subtitle: "Hôtel de Ville → Champs-Élysées — 21 km",
    totalKm: 21,
    category: .walk,
    emoji: "🏃",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0004-0004-0004-000000000041")!,
            km: 0,
            label: "Hôtel de Ville",
            description: "Départ sur le parvis. La Seine est à deux pas, les bâtiments haussmanniens bordent les premiers kilomètres."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0004-0004-0004-000000000042")!,
            km: 7,
            label: "Bois de Vincennes",
            description: "Le poumon vert de l'est parisien. Les allées forestières offrent un répit après les boulevards."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0004-0004-0004-000000000043")!,
            km: 14,
            label: "Place de la Nation",
            description: "La grande place ronde marque le retour vers le centre. Les jambes commencent à parler."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0004-0004-0004-000000000044")!,
            km: 21,
            label: "Champs-Élysées",
            description: "Arrivée sur la plus belle avenue du monde. 21,1 km dans les jambes et tout Paris pour récompense."
        ),
    ]
)

private let journeyWalk42k = Journey(
    id: UUID(uuidString: "F6A7B8C9-0005-0005-0005-000000000005")!,
    name: "Marathon de Paris",
    subtitle: "La boucle mythique — 42 km",
    totalKm: 42,
    category: .walk,
    emoji: "🏅",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0005-0005-0005-000000000051")!,
            km: 0,
            label: "Champs-Élysées",
            description: "Départ au pied de l'Arc de Triomphe. Des dizaines de milliers de coureurs s'élancent chaque année en avril."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0005-0005-0005-000000000052")!,
            km: 10,
            label: "Bois de Boulogne",
            description: "Première grande bouffée d'air vert. Les allées du bois absorbent les premiers kilomètres dans leurs feuillages."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0005-0005-0005-000000000053")!,
            km: 21,
            label: "Mi-parcours — Bastille",
            description: "La moitié est franchie. La place de la Bastille et ses colonnes marquent le point de bascule mental du marathon."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0005-0005-0005-000000000054")!,
            km: 30,
            label: "Bois de Vincennes",
            description: "Le redoutable km 30 — le mur du marathon. Les arbres du bois sont là pour souffler avant le retour."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0005-0005-0005-000000000055")!,
            km: 42,
            label: "Avenue Foch",
            description: "L'arrivée. 42,195 km parcourus à travers Paris. La médaille, les jambes en feu, et la fierté qui ne passe pas."
        ),
    ]
)

private let journeyAmeliePoulain = Journey(
    id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000006")!,
    name: "Amélie Poulain — Montmartre",
    subtitle: "Café des Deux Moulins → Canal Saint-Martin — 4 km",
    totalKm: 4,
    category: .walk,
    emoji: "🎬",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000061")!,
            km: 0,
            label: "Café des Deux Moulins",
            description: "Amélie y est serveuse. On la voit casser la croûte brûlée de la crème brûlée avec le dos de sa cuillère."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000062")!,
            km: 0.8,
            label: "Épicerie Collignon",
            description: "Amélie s'en prend à l'épicier tyrannique : pantoufles réarrangées, réveil déréglé, petite vengeance discrète."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000063")!,
            km: 1.5,
            label: "Marché Saint-Pierre",
            description: "Le quartier textile qu'elle traverse en chemin, entre les rouleaux de tissus empilés sur les trottoirs."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000064")!,
            km: 2.2,
            label: "Son appartement, passage des Abbesses",
            description: "Là où elle vit, observe le monde par sa fenêtre et invente ses petits complots bienveillants."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000065")!,
            km: 2.8,
            label: "Le Consulat",
            description: "Le café où travaille Nino, qu'elle épie de loin avant d'oser l'approcher."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000066")!,
            km: 3.3,
            label: "Parvis du Sacré-Cœur",
            description: "Vue sur tout Paris. Un des lieux de rendez-vous les plus emblématiques du film."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000067")!,
            km: 3.7,
            label: "Ricochets sur le Canal Saint-Martin",
            description: "Amélie fait des ricochets, seule, dans un des instants les plus contemplatifs du film."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0006-0006-0006-000000000068")!,
            km: 4,
            label: "Canal Saint-Martin",
            description: "Fin du parcours au bord de l'eau, dans la lumière si particulière du Paris d'Amélie."
        ),
    ]
)

private let journeyBeforeSunrise = Journey(
    id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000007")!,
    name: "Before Sunrise — Vienne de nuit",
    subtitle: "Gare de Vienne → Pont sur le Danube — 7 km",
    totalKm: 7,
    category: .walk,
    emoji: "🎬",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000071")!,
            km: 0,
            label: "Gare de Vienne",
            description: "Jesse et Céline descendent du train ensemble, sur un coup de tête qui va changer une nuit — et peut-être une vie."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000072")!,
            km: 1,
            label: "Tram nocturne",
            description: "Première vraie conversation, premières confidences, à travers les vitres embuées d'un tramway viennois."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000073")!,
            km: 2,
            label: "Café Sperl",
            description: "Discussion existentielle autour d'un café viennois — l'amour, le temps, la peur de se rater."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000074")!,
            km: 3.5,
            label: "Disquaire, cabine d'écoute",
            description: "Le moment gênant et tendre où ils écoutent un disque ensemble, sans jamais oser se regarder."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000075")!,
            km: 4.5,
            label: "Cimetière central de Vienne",
            description: "Déambulation parmi les tombes, réflexions à voix haute sur le temps qui passe et la mort qui attend."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000076")!,
            km: 5.5,
            label: "Petit parc au bord du Danube",
            description: "Un slam improvisé par un inconnu du parc, pour une poignée de pièces — un des instants les plus tendres du film."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000077")!,
            km: 6.2,
            label: "Grande roue du Prater",
            description: "Premier baiser, suspendu dans une cabine au-dessus des lumières de Vienne."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0007-0007-0007-000000000078")!,
            km: 7,
            label: "Pont sur le Danube",
            description: "L'aube approche. La promesse fragile de se retrouver, six mois plus tard, sur ce même quai."
        ),
    ]
)

private let journeyNottingHill = Journey(
    id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000008")!,
    name: "Notting Hill — Portobello Road",
    subtitle: "Librairie de William → Hôtel Ritz — 3 km",
    totalKm: 3,
    category: .walk,
    emoji: "🎬",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000081")!,
            km: 0,
            label: "Librairie de voyage de William",
            description: "Anna Scott y entre par hasard, incognito, et bouleverse sans le savoir la vie tranquille d'un libraire."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000082")!,
            km: 0.6,
            label: "Portobello Market",
            description: "La traversée du marché au fil des saisons, en un seul plan-séquence devenu culte."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000083")!,
            km: 1.2,
            label: "Le café du coin",
            description: "William renverse du jus d'orange sur Anna en se faisant passer pour un journaliste — un mensonge maladroit et charmant."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000084")!,
            km: 1.8,
            label: "La porte bleue",
            description: "La façade la plus photographiée du film, devenue un symbole du quartier bien au-delà de l'écran."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000085")!,
            km: 2.4,
            label: "Jardin communal secret",
            description: "Ils escaladent la grille pour s'y retrouver, loin des paparazzis, dans un des rares moments de calme du film."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0008-0008-0008-000000000086")!,
            km: 3,
            label: "Hôtel Ritz",
            description: "Conférence de presse finale : William déclare publiquement son amour devant les caméras du monde entier."
        ),
    ]
)

private let journeyRocky = Journey(
    id: UUID(uuidString: "F6A7B8C9-0009-0009-0009-000000000009")!,
    name: "Rocky — les marches du musée",
    subtitle: "Marché italien de Philadelphie → Museum of Art — 3 km",
    totalKm: 3,
    category: .walk,
    emoji: "🎬",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0009-0009-0009-000000000091")!,
            km: 0,
            label: "Marché italien de South Philly",
            description: "Entraînement à l'aube. Rocky salue les commerçants et attrape une orange au vol, sans ralentir."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0009-0009-0009-000000000092")!,
            km: 1,
            label: "Rue résidentielle de South Philly",
            description: "Course matinale à travers les quartiers populaires qui l'ont vu grandir."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0009-0009-0009-000000000093")!,
            km: 2,
            label: "Fontaine de Logan Square",
            description: "Une courte pause pendant l'entraînement, le souffle repris avant la dernière ligne droite."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0009-0009-0009-000000000094")!,
            km: 2.6,
            label: "Escaliers du Philadelphia Museum of Art",
            description: "La montée légendaire, bras levés au sommet — un des instants les plus imités du cinéma."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-0009-0009-0009-000000000095")!,
            km: 3,
            label: "Statue de Rocky",
            description: "Au pied des marches, désormais un lieu de pèlerinage pour les fans venus refaire la montée."
        ),
    ]
)

private let journeyLostInTranslation = Journey(
    id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-00000000000A")!,
    name: "Lost in Translation — Tokyo de nuit",
    subtitle: "Park Hyatt Tokyo → départ du bar — 6 km",
    totalKm: 6,
    category: .walk,
    emoji: "🎬",
    milestones: [
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-0000000000A1")!,
            km: 0,
            label: "Bar du Park Hyatt Tokyo",
            description: "Bob et Charlotte se croisent au bar, un premier regard complice au-dessus de la ville illuminée."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-0000000000A2")!,
            km: 1.5,
            label: "Croisement de Shibuya",
            description: "Immersion dans la foule et les néons de Tokyo — un sentiment de solitude au milieu de la multitude."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-0000000000A3")!,
            km: 3,
            label: "Salle de karaoké",
            description: "Soirée improvisée entre amis. Bob chante « More Than This », perruque rose sur la tête."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-0000000000A4")!,
            km: 4.5,
            label: "Golden Gai (Shinjuku)",
            description: "Ruelles de bars minuscules, à peine plus larges qu'un couloir — la nuit tokyoïte la plus électrique."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-0000000000A5")!,
            km: 5.5,
            label: "Temple bouddhiste",
            description: "Charlotte s'y rend seule, en quête de sens, loin du vertige de la ville."
        ),
        Milestone(
            id: UUID(uuidString: "F6A7B8C9-000A-000A-000A-0000000000A6")!,
            km: 6,
            label: "Départ du Park Hyatt",
            description: "Un adieu chuchoté à l'oreille, resté l'un des mystères les plus discutés du cinéma."
        ),
    ]
)

// MARK: - Sentiers

private let journeyGR20 = Journey(
    id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000001")!,
    name: "GR20 complet",
    subtitle: "Le trek le plus difficile d'Europe",
    totalKm: 180,
    category: .trail,
    emoji: "🏔️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000011")!,
            km: 0,
            label: "Calenzana",
            description: "Départ officiel du GR20, au pied des montagnes corses. Le sentier plonge immédiatement dans le maquis odorant."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000014")!,
            km: 19,
            label: "Refuge de Carrozzu",
            description: "Passerelle suspendue de la Spasimata et dalles inclinées : le GR20 montre déjà les dents. Le refuge s'accroche au-dessus d'un cirque sauvage."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000015")!,
            km: 33,
            label: "Auberge U Vallone",
            description: "Au pied du Monte Cinto, plus haut sommet de Corse. La partie la plus alpine du parcours nord est franchie."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000016")!,
            km: 47,
            label: "Col de Vergio",
            description: "Point le plus haut atteint par une route en Corse, entre forêts de pins laricio et estives. Le sentier bascule vers le centre de l'île."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000017")!,
            km: 62,
            label: "Refuge de Manganu",
            description: "Au bord des pozzines, ces pelouses spongieuses gorgées d'eau. Les lacs glaciaires de Nino et Capitellu ne sont plus loin."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000018")!,
            km: 72,
            label: "Refuge de Petra Piana",
            description: "Perché sous les crêtes, face à un panorama de sommets déchiquetés. Le cœur minéral du GR20."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000012")!,
            km: 88,
            label: "Vizzavona",
            description: "Mi-parcours, accessible par le train. La forêt de laricio offre une pause bienvenue après les crêtes exposées."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000019")!,
            km: 113,
            label: "Refuge de Prati",
            description: "Vaste replat herbeux ouvert sur la mer Tyrrhénienne à l'est. Le sud, plus doux, commence à se dessiner."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-00000000001A")!,
            km: 123,
            label: "Refuge d'Usciolu",
            description: "Perché sur l'arête, réputé pour ses couchers de soleil. La redoutable « arête a Monda » attend au sud."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-00000000001B")!,
            km: 140,
            label: "Refuge d'Asinau",
            description: "Sous les aiguilles de Bavella, cathédrales de granit orange. L'un des plus beaux décors de toute la traversée."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-00000000001C")!,
            km: 165,
            label: "Refuge de Paliri",
            description: "Dernier refuge avant l'arrivée, dans les pins et le maquis. La mer est déjà là, en contrebas."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000013")!,
            km: 180,
            label: "Conca",
            description: "Arrivée au bout du GR20, village perché au-dessus de Porto-Vecchio. La mer Méditerranée scintille au loin."
        ),
    ]
)

private let journeyCaminoFinal = Journey(
    id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000002")!,
    name: "Camino Francés — tronçon final",
    subtitle: "Sarria → Santiago de Compostela",
    totalKm: 111,
    category: .trail,
    emoji: "⚜️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000021")!,
            km: 0,
            label: "Sarria",
            description: "Dernière ville permettant d'obtenir la Compostela en marchant le minimum requis — 100 km à pied."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000026")!,
            km: 12,
            label: "Morgade",
            description: "Hameau minuscule où se dresse la fameuse borne des 100 kilomètres. À partir d'ici, chaque pas rapproche vraiment de Santiago."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000022")!,
            km: 22,
            label: "Portomarín",
            description: "Village reconstruit après que l'ancien fut noyé sous le lac de Belesar dans les années 1960."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000027")!,
            km: 40,
            label: "Eirexe",
            description: "Petit lieu-dit galicien parmi les hórreos, ces greniers de pierre sur pilotis. La campagne défile au rythme des vaches."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000023")!,
            km: 48,
            label: "Palas de Rei",
            description: "Nom lié aux rois wisigoths. Étape tranquille à mi-chemin du tronçon final, cœur de la Galice verte."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000028")!,
            km: 62,
            label: "Melide",
            description: "Étape gourmande, capitale du poulpe à la galicienne — le pulpo á feira. Les pèlerins s'y attablent avant la dernière ligne."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000024")!,
            km: 80,
            label: "Arzúa",
            description: "Capitale du fromage galicien. À une journée de Santiago, les pèlerins sentent déjà la fin du chemin."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000029")!,
            km: 99,
            label: "O Pedrouzo",
            description: "Dernière halte avant la ville sainte, dans les bois d'eucalyptus. Demain, Santiago."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-00000000002A")!,
            km: 106,
            label: "Monte do Gozo",
            description: "Le « mont de la joie » : de sa colline, les pèlerins aperçoivent pour la première fois les flèches de la cathédrale."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000025")!,
            km: 111,
            label: "Santiago de Compostela",
            description: "La cathédrale surgit sur la Plaza del Obradoiro après des semaines de marche. La Compostela est méritée."
        ),
    ]
)

private let journeyCaminoComplet = Journey(
    id: UUID(uuidString: "C3D4E5F6-0003-0003-0003-000000000003")!,
    name: "Camino Francés — complet",
    subtitle: "Saint-Jean-Pied-de-Port → Santiago",
    totalKm: 780,
    category: .trail,
    emoji: "🐚",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0003-0003-0003-000000000031")!,
            km: 0,
            label: "Saint-Jean-Pied-de-Port",
            description: "Porte d'entrée pyrénéenne du Camino, dernier village français avant la traversée des cols vers l'Espagne."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0003-0003-0003-000000000032")!,
            km: 75,
            label: "Pampelune",
            description: "Capitale de la Navarre, célèbre pour ses fêtes de San Fermín. Premier grand repère après les Pyrénées."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0003-0003-0003-000000000033")!,
            km: 295,
            label: "Burgos",
            description: "Cathédrale gothique majestueuse, tombe du Cid Campeador. Le plateau de la Meseta commence ici."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0003-0003-0003-000000000034")!,
            km: 500,
            label: "León",
            description: "Vitraux extraordinaires dans la cathédrale. La ville marque la fin de la Meseta et l'entrée en Galice."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0003-0003-0003-000000000035")!,
            km: 780,
            label: "Santiago de Compostela",
            description: "La cathédrale de Santiago, destination de millions de pèlerins depuis le Moyen Âge. Le Botafumeiro se balance dans la nef."
        ),
    ]
)

private let journeyViaPlata = Journey(
    id: UUID(uuidString: "C3D4E5F6-0004-0004-0004-000000000004")!,
    name: "Via de la Plata",
    subtitle: "Séville → Santiago, le Camino le plus long",
    totalKm: 1000,
    category: .trail,
    emoji: "🌿",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0004-0004-0004-000000000041")!,
            km: 0,
            label: "Séville",
            description: "Départ sous le soleil andalou, depuis la cathédrale gothique la plus grande du monde."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0004-0004-0004-000000000042")!,
            km: 65,
            label: "Mérida",
            description: "Ancienne Emerita Augusta romaine, capitale de la Lusitanie. Théâtre et amphithéâtre intacts sous le soleil d'Estrémadure."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0004-0004-0004-000000000043")!,
            km: 450,
            label: "Salamanque",
            description: "L'université la plus ancienne d'Espagne. La Plaza Mayor dorée est l'une des plus belles d'Europe."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0004-0004-0004-000000000044")!,
            km: 570,
            label: "Zamora",
            description: "Ville aux douze églises romanes, perchée sur un éperon rocheux au-dessus du Duero."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0004-0004-0004-000000000045")!,
            km: 1000,
            label: "Santiago de Compostela",
            description: "Arrivée à Compostelle après le plus long des Caminos. Une Compostela doublement méritée."
        ),
    ]
)

private let journeyTMB = Journey(
    id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000005")!,
    name: "Tour du Mont Blanc",
    subtitle: "France, Italie, Suisse — 10 étapes",
    totalKm: 170,
    category: .trail,
    emoji: "🏔️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000051")!,
            km: 0,
            label: "Les Houches",
            description: "Départ traditionnel du TMB, à quelques kilomètres de Chamonix. Le Mont Blanc domine déjà les crêtes."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000055")!,
            km: 18,
            label: "Les Contamines-Montjoie",
            description: "Vallée verdoyante au pied du Col du Bonhomme. Dernier village animé avant la haute montagne côté français."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000056")!,
            km: 34,
            label: "Les Chapieux",
            description: "Hameau isolé au fond d'un vallon sauvage, après les cols du Bonhomme et de la Croix. La solitude alpine dans toute sa pureté."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000057")!,
            km: 48,
            label: "Refuge Elisabetta",
            description: "Franchissement du Col de la Seigne, porte d'entrée en Italie. Le glacier de la Lée Blanche domine le refuge."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000052")!,
            km: 75,
            label: "Courmayeur",
            description: "Côté italien du massif. Village alpin animé au pied du versant sud du Mont Blanc, sous un soleil plus généreux."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000058")!,
            km: 90,
            label: "Refuge Bonatti",
            description: "Balcon suspendu face au versant italien du Mont Blanc, dédié au grand alpiniste Walter Bonatti. L'une des plus belles vues du tour."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000059")!,
            km: 105,
            label: "La Fouly",
            description: "Entrée en Suisse par le Grand Col Ferret. Le val Ferret valaisan déroule ses alpages impeccables."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000053")!,
            km: 120,
            label: "Champex",
            description: "Lac de montagne suisse d'une sérénité absolue, perché à 1 470 mètres entre mélèzes et reflets parfaits."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-00000000005A")!,
            km: 138,
            label: "Col de la Forclaz",
            description: "Balcon au-dessus de la vallée du Rhône, près de Trient et de son glacier. Le retour vers la France se prépare."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-00000000005B")!,
            km: 155,
            label: "Tré-le-Champ",
            description: "Après le Col de Balme, retour en France face à la chaîne des Aiguilles Rouges. Les échelles métalliques pimentent la descente."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000054")!,
            km: 170,
            label: "Chamonix",
            description: "Retour en France dans la capitale mondiale de l'alpinisme. Le tour est bouclé sous les aiguilles."
        ),
    ]
)

private let journeyViaFrancigena = Journey(
    id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000006")!,
    name: "Via Francigena — tronçon final",
    subtitle: "Lucques → Rome, sur les pas de Sigéric",
    totalKm: 420,
    category: .trail,
    emoji: "🕊️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000061")!,
            km: 0,
            label: "Lucques",
            description: "Cité médiévale toscane aux remparts intacts. Point de départ de la section finale vers Rome."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000066")!,
            km: 18,
            label: "Altopascio",
            description: "Ancien hospice des Chevaliers du Tau, qui guidaient les pèlerins à travers les marais. Sa cloche sonnait le soir pour rallier les égarés."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000067")!,
            km: 45,
            label: "San Miniato",
            description: "Perchée entre Florence et Pise, dominée par la tour de Frédéric II. Ses collines embaument la truffe blanche à l'automne."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000062")!,
            km: 80,
            label: "San Gimignano",
            description: "Les tours médiévales surgissent au-dessus des vignes à Vernaccia. Classée au patrimoine mondial de l'Unesco."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000068")!,
            km: 100,
            label: "Monteriggioni",
            description: "Bourg fortifié aux quatorze tours, cité par Dante dans l'Enfer. Un anneau de pierre intact posé sur une colline."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000063")!,
            km: 110,
            label: "Sienne",
            description: "Le Palio, la Piazza del Campo en coquille, les couleurs siennées. Joyau de la Toscane médiévale."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000069")!,
            km: 160,
            label: "San Quirico d'Orcia",
            description: "Au cœur du Val d'Orcia et de ses collines ondulées bordées de cyprès. Les Horti Leonini offrent au pèlerin un jardin Renaissance."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-00000000006A")!,
            km: 195,
            label: "Radicofani",
            description: "Forteresse posée sur un piton volcanique, longtemps repaire du brigand Ghino di Tacco. La vue embrasse toute la Toscane du Sud."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-00000000006B")!,
            km: 225,
            label: "Acquapendente",
            description: "Sa basilique abrite une réplique du Saint-Sépulcre, étape spirituelle majeure du chemin. On entre ici dans le Latium."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-00000000006C")!,
            km: 250,
            label: "Bolsena",
            description: "Sur les rives du plus grand lac volcanique d'Europe. Le miracle eucharistique de 1263 y fit naître la Fête-Dieu."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-00000000006D")!,
            km: 270,
            label: "Montefiascone",
            description: "Sa coupole domine le lac de Bolsena. Le vin « Est! Est!! Est!!! » y aurait été baptisé par un évêque trop gourmand."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000064")!,
            km: 310,
            label: "Viterbe",
            description: "Ancienne résidence des papes au XIIIe siècle, cité médiévale remarquablement conservée dans le Latium."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-00000000006E")!,
            km: 360,
            label: "Sutri",
            description: "Cité étrusque creusée dans le tuf, avec son amphithéâtre taillé à même la roche. La porte légendaire du Latium romain."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-00000000006F")!,
            km: 405,
            label: "La Storta",
            description: "Dernière halte avant Rome, où saint Ignace eut sa vision. Du Monte Mario voisin, les pèlerins découvrent enfin la coupole de Saint-Pierre."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000065")!,
            km: 420,
            label: "Rome",
            description: "La basilique Saint-Pierre au bout du chemin. Le pèlerin arrive dans la Ville Éternelle après des semaines de Toscane."
        ),
    ]
)

private let journeySentierDouaniers = Journey(
    id: UUID(uuidString: "C3D4E5F6-0007-0007-0007-000000000007")!,
    name: "Sentier des Douaniers",
    subtitle: "Cap Fréhel → Dahouet — 65 km",
    totalKm: 65,
    category: .trail,
    emoji: "🌊",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0007-0007-0007-000000000071")!,
            km: 0,
            label: "Cap Fréhel",
            description: "Le grand phare rouge et blanc domine des falaises de grès rose. Départ face à la Manche, embruns garantis."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0007-0007-0007-000000000072")!,
            km: 15,
            label: "Pointe de la Latte",
            description: "Le fort la Latte, forteresse médiévale posée sur un îlot rocheux relié par une passerelle au-dessus du vide."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0007-0007-0007-000000000073")!,
            km: 35,
            label: "Erquy",
            description: "Le port aux bateaux de pêche à la coquille Saint-Jacques, niché entre landes de bruyère et plages de sable fin."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0007-0007-0007-000000000074")!,
            km: 45,
            label: "Cap d'Erquy",
            description: "Falaises de grès rose et landes sauvages. Un des plus beaux points de vue de la Côte d'Émeraude."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0007-0007-0007-000000000075")!,
            km: 65,
            label: "Dahouet",
            description: "Petit port discret niché dans une ria, longtemps ignoré des cartes marines pour rester secret des pêcheurs locaux."
        ),
    ]
)

private let journeyStevenson = Journey(
    id: UUID(uuidString: "C3D4E5F6-0008-0008-0008-000000000008")!,
    name: "Chemin de Stevenson",
    subtitle: "Le Puy-en-Velay → La Bastide-Puylaurent — 75 km",
    totalKm: 75,
    category: .trail,
    emoji: "🫏",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0008-0008-0008-000000000081")!,
            km: 0,
            label: "Le Puy-en-Velay",
            description: "Départ au pied de la statue de Notre-Dame-de-France, sur les traces de Robert Louis Stevenson et de son ânesse Modestine."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0008-0008-0008-000000000082")!,
            km: 21,
            label: "Bouchet-Saint-Nicolas",
            description: "Le village où Stevenson acheta Modestine. Les premiers plateaux du Velay, à l'air déjà plus rude."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0008-0008-0008-000000000083")!,
            km: 44,
            label: "Pradelles",
            description: "Village fortifié perché sur son éperon rocheux, aux portes de la Lozère et de ses grands espaces vides."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0008-0008-0008-000000000084")!,
            km: 58,
            label: "Langogne",
            description: "Halte au bord de l'Allier naissant. Stevenson y écrivit ses premières impressions désabusées sur son ânesse récalcitrante."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0008-0008-0008-000000000085")!,
            km: 75,
            label: "La Bastide-Puylaurent",
            description: "Aux portes des Cévennes, le point d'arrivée de cette première étape — le chemin continue vers l'Ardèche pour qui veut poursuivre."
        ),
    ]
)

private let journeyGR20Nord = Journey(
    id: UUID(uuidString: "C3D4E5F6-0009-0009-0009-000000000009")!,
    name: "GR20 Nord",
    subtitle: "Calenzana → Vizzavona — 90 km",
    totalKm: 90,
    category: .trail,
    emoji: "⛰️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0009-0009-0009-000000000091")!,
            km: 0,
            label: "Calenzana",
            description: "Le clocher baroque du village balata marque le vrai départ du GR20 — réputé le plus difficile d'Europe."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0009-0009-0009-000000000092")!,
            km: 19,
            label: "Refuge de Carrozzu",
            description: "Passerelle suspendue de la Spasimata et dalles inclinées : le GR20 montre déjà les dents. Le refuge s'accroche au-dessus d'un cirque sauvage."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0009-0009-0009-000000000093")!,
            km: 35,
            label: "Refuge de Tighjettu",
            description: "Isolé au cœur du massif, entouré de sommets acérés. Un des refuges les plus reculés de toute la traversée."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0009-0009-0009-000000000094")!,
            km: 55,
            label: "Refuge de Ciottulu di i Mori",
            description: "Perché à plus de 1 900 m sous le Paglia Orba, un des plus beaux promontoires de l'île pour un lever de soleil."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0009-0009-0009-000000000095")!,
            km: 90,
            label: "Vizzavona",
            description: "Le village-frontière entre le nord alpin et le sud plus doux du GR20 — la moitié du chemin, à l'ombre de la forêt de pins laricio."
        ),
    ]
)

// MARK: - Histoire

private let journeyRouteRoyalePerse = Journey(
    id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000001")!,
    name: "Route Royale Perse",
    subtitle: "Suse → Sardes — l'autoroute de Darius Ier",
    totalKm: 2700,
    category: .history,
    emoji: "👑",
    milestones: [
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000011")!,
            km: 0,
            label: "Suse",
            description: "Capitale perse, résidence d'hiver de Darius Ier. Point de départ de la route royale la plus rapide du monde antique."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000015")!,
            km: 350,
            label: "Pasargades",
            description: "Première capitale perse fondée par Cyrus le Grand, où se dresse son tombeau. Berceau de la dynastie achéménide."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000012")!,
            km: 700,
            label: "Persépolis",
            description: "Capitale cérémonielle achéménide, où les tributs de l'empire entier affluaient à chaque printemps."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000016")!,
            km: 1050,
            label: "Ecbatane",
            description: "Capitale des Mèdes, résidence d'été aux sept murailles colorées. Relais stratégique sur la route de l'ouest."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000013")!,
            km: 1400,
            label: "Mésopotamie",
            description: "Traversée du cœur de l'empire entre Tigre et Euphrate, berceau des civilisations et grenier du monde perse."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000017")!,
            km: 1650,
            label: "Babylone",
            description: "La cité de la porte d'Ishtar et des jardins suspendus. Le cœur battant du monde antique sur l'Euphrate."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000018")!,
            km: 1900,
            label: "Ninive",
            description: "Ancienne capitale assyrienne sur le Tigre, aux palais couverts de bas-reliefs de lions et de rois chasseurs."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000019")!,
            km: 2100,
            label: "Harran",
            description: "Cité caravanière de Haute-Mésopotamie, célèbre pour son temple lunaire. Carrefour vers l'Anatolie."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-00000000001A")!,
            km: 2300,
            label: "Passage de l'Euphrate",
            description: "Le grand fleuve franchi sur des barques de peaux gonflées. La route bascule vers les hauts plateaux anatoliens."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-00000000001B")!,
            km: 2500,
            label: "Gordion",
            description: "Capitale phrygienne au nœud légendaire qu'Alexandre trancherait plus tard. Dernière grande étape avant la Lydie."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000014")!,
            km: 2700,
            label: "Sardes",
            description: "Terminus occidental sur la mer Égée. Les cavaliers royaux couvraient ce trajet en sept jours grâce aux relais de poste."
        ),
    ]
)

private let journeyAlexandrePerse = Journey(
    id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000002")!,
    name: "Alexandre le Grand — Campagne perse",
    subtitle: "Macédoine → Persépolis",
    totalKm: 5000,
    category: .history,
    emoji: "⚔️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000021")!,
            km: 0,
            label: "Pella",
            description: "Capitale macédonienne où Alexandre fut éduqué par Aristote. Départ de la plus grande armée que la Grèce ait jamais vue."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000022")!,
            km: 400,
            label: "Bataille du Granique",
            description: "Première victoire décisive contre les satrapes perses en 334 av. J.-C. Alexandre manque d'y être tué."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000026")!,
            km: 700,
            label: "Sardes",
            description: "La riche capitale lydienne se rend sans combat. L'Ionie grecque est libérée de la tutelle perse."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000027")!,
            km: 900,
            label: "Halicarnasse",
            description: "Siège de la cité carienne et de son port. La flotte perse perd sa dernière grande base en mer Égée."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000023")!,
            km: 1100,
            label: "Bataille d'Issos",
            description: "Darius III en fuite, sa famille capturée. L'empire perse commence à vaciller sous les coups macédoniens."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000028")!,
            km: 1500,
            label: "Siège de Tyr",
            description: "Sept mois de siège contre la cité phénicienne insulaire. Alexandre fait bâtir une digue jusqu'aux remparts."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000029")!,
            km: 2100,
            label: "Alexandrie d'Égypte",
            description: "Alexandre trace lui-même le plan de la ville qui portera son nom et deviendra un phare de la culture antique."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-00000000002A")!,
            km: 2500,
            label: "Bataille de Gaugamèles",
            description: "L'affrontement décisif contre Darius III. L'Empire perse achéménide s'effondre pour de bon en 331 av. J.-C."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000024")!,
            km: 2800,
            label: "Babylone",
            description: "La plus grande ville du monde prise sans combat. Alexandre se présente en libérateur plutôt qu'en conquérant."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-00000000002B")!,
            km: 3600,
            label: "Suse",
            description: "Le trésor royal perse tombe intact aux mains d'Alexandre. Des richesses inouïes changent de camp."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-00000000002C")!,
            km: 4200,
            label: "Portes Persiques",
            description: "Défilé montagneux défendu par les Perses, forcé de nuit par une manœuvre de contournement. Dernier verrou avant la capitale."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000025")!,
            km: 5000,
            label: "Persépolis",
            description: "La cité des rois achéménides incendiée après sa prise. La Perse est conquise, l'objectif d'Alexandre accompli."
        ),
    ]
)

private let journeyAlexandreComplet = Journey(
    id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000003")!,
    name: "Alexandre le Grand — Épopée complète",
    subtitle: "Macédoine → Inde — 8 ans de conquête",
    totalKm: 35000,
    category: .history,
    emoji: "🌍",
    milestones: [
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000031")!,
            km: 0,
            label: "Pella",
            description: "Capitale macédonienne, départ de la plus grande épopée militaire de l'Antiquité en 334 av. J.-C."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000032")!,
            km: 400,
            label: "Troie",
            description: "Premier arrêt symbolique — Alexandre se recueille sur la tombe d'Achille, le héros auquel il s'identifiait."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000039")!,
            km: 1100,
            label: "Bataille d'Issos",
            description: "Première grande victoire contre Darius III en personne. La famille royale perse tombe aux mains d'Alexandre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-00000000003A")!,
            km: 2100,
            label: "Tyr et l'Égypte",
            description: "Après sept mois de siège contre Tyr, Alexandre descend en Égypte et fonde Alexandrie sur le delta du Nil."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000033")!,
            km: 4000,
            label: "Gaugamèles",
            description: "Victoire décisive contre Darius III qui met fin à l'Empire perse achéménide en 331 av. J.-C."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000034")!,
            km: 5000,
            label: "Persépolis",
            description: "Capitale cérémonielle persane. L'incendie reste l'acte le plus controversé de toute la conquête."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-00000000003B")!,
            km: 6500,
            label: "Ecbatane",
            description: "Poursuite de Darius, retrouvé assassiné par ses propres satrapes. Alexandre lui offre des funérailles royales."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000035")!,
            km: 8000,
            label: "Bactres",
            description: "Aux portes de l'Asie centrale, Alexandre épouse Roxane. La résistance bactriène est la plus farouche rencontrée."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-00000000003C")!,
            km: 10000,
            label: "Sogdiane",
            description: "Deux ans de guérilla épuisante contre Spitamène dans les montagnes d'Asie centrale. La conquête la plus dure."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-00000000003D")!,
            km: 12000,
            label: "Hindū Kush",
            description: "Franchissement des montagnes enneigées vers l'Inde. L'armée souffre du froid, de l'altitude et de la faim."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000036")!,
            km: 14000,
            label: "Taxila",
            description: "Première grande cité indienne. Le roi Poros attend sur l'Hydaspe avec deux cents éléphants de guerre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-00000000003E")!,
            km: 15000,
            label: "Bataille de l'Hydaspe",
            description: "Victoire contre Poros et ses éléphants, sous la pluie de mousson. La bataille la plus coûteuse de la campagne."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000037")!,
            km: 17000,
            label: "Rivière Beas",
            description: "La mutinerie. Les soldats refusent d'avancer vers l'Inde profonde. Alexandre pleure dans sa tente, puis accepte de rentrer."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-00000000003F")!,
            km: 21000,
            label: "Désert de Gédrosie",
            description: "La retraite cauchemardesque. Des milliers d'hommes meurent de soif dans les sables du Makran."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000040")!,
            km: 26000,
            label: "Noces de Suse",
            description: "Alexandre marie ses officiers à des princesses perses pour fondre Grecs et Orientaux en un seul peuple."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000041")!,
            km: 30000,
            label: "Deuil d'Héphaïstion",
            description: "La mort de son ami le plus cher, à Ecbatane, plonge Alexandre dans un deuil dévastateur."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000038")!,
            km: 35000,
            label: "Babylone",
            description: "Mort d'Alexandre à 32 ans, en 323 av. J.-C. Son empire, le plus vaste jamais conquis, est aussitôt démembré."
        ),
    ]
)

private let journeyRouteSoie = Journey(
    id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000004")!,
    name: "Route de la Soie",
    subtitle: "Chang'an → Rome — 2 000 ans de commerce",
    totalKm: 6400,
    category: .history,
    emoji: "🧵",
    milestones: [
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000041")!,
            km: 0,
            label: "Xi'an",
            description: "Ancienne Chang'an, capitale des Han et des Tang. Les caravanes de chameaux chargées de soie partaient d'ici vers l'ouest."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000047")!,
            km: 800,
            label: "Lanzhou",
            description: "Verrou du fleuve Jaune, porte du corridor du Hexi. Les caravanes s'y regroupent avant les grands déserts."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000048")!,
            km: 1300,
            label: "Jiayuguan",
            description: "Extrémité ouest de la Grande Muraille, dernière forteresse de l'empire. Au-delà commençait l'inconnu."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000042")!,
            km: 2000,
            label: "Dunhuang",
            description: "Oasis du désert de Gobi, gardienne des Grottes de Mogao aux mille bouddhas sculptés dans la roche ocre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000049")!,
            km: 2600,
            label: "Tourfan",
            description: "Oasis sous le niveau de la mer, irriguée par les canaux karez. Vignes et bouddhas au cœur de la fournaise du Taklamakan."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-00000000004A")!,
            km: 3000,
            label: "Kashgar",
            description: "Grand carrefour au pied du Pamir, où se rejoignent les routes du nord et du sud du désert."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000043")!,
            km: 3500,
            label: "Samarcande",
            description: "Joyau de l'Asie centrale, carrefour de toutes les caravanes. Tamerlan en fit la capitale de son empire au XIVe siècle."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-00000000004B")!,
            km: 3900,
            label: "Boukhara",
            description: "Ville sainte aux cent médersas, joyau spirituel et marchand de l'Asie centrale."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-00000000004C")!,
            km: 4200,
            label: "Merv",
            description: "Oasis géante du Turkménistan, l'une des plus grandes villes du monde médiéval avant sa destruction par les Mongols."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000044")!,
            km: 4500,
            label: "Persépolis",
            description: "L'ancienne capitale perse ruinée par Alexandre, toujours imposante sur le passage des marchands."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-00000000004D")!,
            km: 5100,
            label: "Bagdad",
            description: "Capitale abbasside et sa Maison de la Sagesse, où le savoir grec, perse et indien se traduisait en arabe."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000045")!,
            km: 5800,
            label: "Constantinople",
            description: "La ville-carrefour entre Europe et Asie, où Orient et Occident échangeaient richesses et savoirs depuis des siècles."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000046")!,
            km: 6400,
            label: "Rome",
            description: "Terminus occidental. La soie chinoise habillait les sénateurs romains. Deux empires reliés sans jamais se rencontrer."
        ),
    ]
)

private let journeyMarcoPolo = Journey(
    id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000005")!,
    name: "Marco Polo — Venise → Chine",
    subtitle: "24 ans de voyage à la cour de Kubilaï Khan",
    totalKm: 12000,
    category: .history,
    emoji: "🗺️",
    milestones: [
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000051")!,
            km: 0,
            label: "Venise",
            description: "Départ en 1271 avec son père et son oncle, marchands habitués des routes orientales."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000056")!,
            km: 1200,
            label: "Acre",
            description: "Escale en Terre sainte. Les Polo y obtiennent des lettres du pape et de l'huile du Saint-Sépulcre pour le Grand Khan."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000052")!,
            km: 2000,
            label: "Constantinople",
            description: "Première grande escale dans la ville-carrefour de la Méditerranée orientale, centre du commerce mondial."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000057")!,
            km: 2800,
            label: "Trébizonde",
            description: "Port de la mer Noire, terminus des routes caravanières d'Anatolie orientale."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000058")!,
            km: 3600,
            label: "Tabriz",
            description: "Grande cité marchande de Perse, plaque tournante des perles, des soies et des épices."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000053")!,
            km: 5000,
            label: "Ormuz",
            description: "Port du Golfe Persique. Marco vit des navires si fragiles qu'il refusa d'embarquer et continua par voie terrestre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000059")!,
            km: 5800,
            label: "Kerman",
            description: "Ville persane réputée pour ses turquoises et ses tapis. Les Polo renoncent à la mer pour la piste terrestre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-00000000005A")!,
            km: 6200,
            label: "Balkh",
            description: "L'antique cité afghane, « mère des villes », ravagée par Gengis Khan mais toujours sur la route de l'est."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-00000000005B")!,
            km: 6600,
            label: "Pamir",
            description: "Le « toit du monde ». Marco décrit un plateau si haut qu'aucun oiseau n'y vole et que le feu y brûle pâle."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000054")!,
            km: 7000,
            label: "Kashgar",
            description: "Oasis mythique au pied du Pamir, carrefour des routes vers l'Inde, la Perse et la Chine profonde."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-00000000005C")!,
            km: 8000,
            label: "Désert du Taklamakan",
            description: "La traversée du « désert où l'on entre mais d'où l'on ne sort pas ». Des voix fantômes égarent les caravanes, dit Marco."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-00000000005D")!,
            km: 9500,
            label: "Dunhuang",
            description: "Les grottes aux mille bouddhas marquent l'entrée dans le monde chinois. Le Grand Khan n'est plus si loin."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-00000000005E")!,
            km: 10800,
            label: "Shangdu",
            description: "Xanadu, la résidence d'été de Kubilaï Khan et son palais de plaisir devenu légendaire."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000055")!,
            km: 12000,
            label: "Pékin",
            description: "La cour de Kubilaï Khan. Marco Polo y passa dix-sept ans comme gouverneur et émissaire du Grand Khan."
        ),
    ]
)

private let journeyHannibal = Journey(
    id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000006")!,
    name: "Hannibal — traversée des Alpes",
    subtitle: "Carthagène → Italie — 218 av. J.-C.",
    totalKm: 1500,
    category: .history,
    emoji: "🐘",
    milestones: [
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000061")!,
            km: 0,
            label: "Carthagène (Nouvelle-Carthage)",
            description: "Départ de l'armée punique, éléphants en tête. Hannibal a juré une haine éternelle à Rome."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000062")!,
            km: 130,
            label: "Passage de l'Èbre",
            description: "Dernier fleuve avant la Gaule. L'armée s'allège des troupes jugées les moins sûres avant de s'engager plus loin."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000063")!,
            km: 350,
            label: "Pyrénées franchies",
            description: "Le col du Perthus laisse les tribus ibères derrière. Devant, la Gaule tout entière reste à traverser."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000064")!,
            km: 550,
            label: "Gaule narbonnaise",
            description: "Marche à travers un territoire officiellement neutre, mais où chaque tribu croisée peut basculer dans un camp ou l'autre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000065")!,
            km: 750,
            label: "Passage du Rhône",
            description: "Les éléphants transbordés sur des radeaux, terrifiés par l'eau, face aux Volques massés sur l'autre rive."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000066")!,
            km: 950,
            label: "Contreforts alpins",
            description: "Les Allobroges harcèlent la colonne dans les défilés étroits. Les premiers chariots basculent dans le vide."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000067")!,
            km: 1100,
            label: "Ascension du col",
            description: "Neige précoce, éboulements, la colonne s'étire sur des kilomètres. Le froid tue plus sûrement que les tribus locales."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000068")!,
            km: 1200,
            label: "Sommet du col",
            description: "Hannibal montre à ses hommes épuisés la plaine du Pô en contrebas. L'Italie, enfin visible, redonne courage à l'armée."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-000000000069")!,
            km: 1300,
            label: "Descente périlleuse",
            description: "Verglas et glissades sur un sentier à peine tracé. Plusieurs éléphants glissent et sont perdus dans la descente."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-00000000006A")!,
            km: 1400,
            label: "Sortie des Alpes",
            description: "Le territoire des Taurins s'ouvre enfin. Après quinze jours de montagne, l'armée touche la plaine italienne."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-00000000006B")!,
            km: 1450,
            label: "Siège de Turin",
            description: "Première victoire sur le sol italien. La cité prise sert de base de ravitaillement pour l'armée exsangue."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0006-0006-0006-00000000006C")!,
            km: 1500,
            label: "Bataille de la Trébie",
            description: "Première grande victoire face aux légions romaines. Rome découvre qu'un général vient de traverser l'infranchissable."
        ),
    ]
)

// MARK: - Mythes & Épopées

private let journeyOdysseeReel = Journey(
    id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000001")!,
    name: "L'Odyssée — trajet réel",
    subtitle: "Troie → Ithaque en ligne droite — 10 ans d'errance",
    totalKm: 900,
    category: .myth,
    emoji: "🌊",
    milestones: [
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000011")!,
            km: 0,
            label: "Troie",
            description: "La guerre achevée, Ulysse prend la mer. Ithaque n'est qu'à quelques jours de navigation favorable."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000017")!,
            km: 150,
            label: "Lotophages — Djerba",
            description: "Chez les mangeurs de lotus, souvent situés à Djerba. Trois marins goûtent le fruit de l'oubli et refusent de repartir."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000012")!,
            km: 350,
            label: "Cyclopes — Sicile",
            description: "L'île de Polyphème. Ulysse lui crève l'œil avec un pieu d'olivier et s'échappe sous le ventre d'une brebis."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000018")!,
            km: 450,
            label: "Éole — Îles Éoliennes",
            description: "Le dieu des vents enferme les vents contraires dans une outre. Ouverte par des marins jaloux, elle rejette la flotte au large."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000019")!,
            km: 500,
            label: "Lestrygons",
            description: "Les géants cannibales fracassent onze des douze navires à coups de rochers. Seul celui d'Ulysse en réchappe."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000013")!,
            km: 550,
            label: "Circé — Monte Circeo",
            description: "La magicienne transforme les compagnons en pourceaux. Ulysse résiste grâce à l'herbe magique de Hermès, puis reste un an."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000014")!,
            km: 620,
            label: "Sirènes — Golfe de Sorrente",
            description: "Ulysse se fait attacher au mât pour entendre le chant fatal sans y succomber. Les rameurs ont les oreilles bouchées de cire."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000015")!,
            km: 650,
            label: "Charybde & Scylla — Détroit de Messine",
            description: "Entre le monstre aux six têtes et le tourbillon dévoreur de navires, six compagnons périssent."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-00000000001A")!,
            km: 780,
            label: "Ogygie — Calypso",
            description: "L'île de la nymphe qui le retient et lui offre l'immortalité. Il préfère Ithaque et repart sur un simple radeau."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-00000000001B")!,
            km: 850,
            label: "Phéaciens — Corfou",
            description: "Les marins de Schérie, souvent identifiée à Corfou, l'écoutent puis le déposent endormi sur sa terre natale."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000016")!,
            km: 900,
            label: "Ithaque",
            description: "Retour après dix ans. Pénélope a résisté, Télémaque a grandi. Il reste les prétendants à éliminer à l'arc."
        ),
    ]
)

private let journeyOdysseeComplet = Journey(
    id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000002")!,
    name: "L'Odyssée — voyage complet estimé",
    subtitle: "Avec tous les détours d'Ulysse — mer Méditerranée",
    totalKm: 8000,
    category: .myth,
    emoji: "🔱",
    milestones: [
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000021")!,
            km: 0,
            label: "Troie",
            description: "Départ après dix ans de siège. La flotte d'Ulysse compte douze navires et leurs équipages au complet."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000029")!,
            km: 250,
            label: "Cicones — Ismaros",
            description: "Le premier pillage après Troie tourne mal : les Cicones contre-attaquent et tuent soixante-douze hommes d'Ulysse."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000022")!,
            km: 600,
            label: "Pays des Lotophages",
            description: "Trois compagnons mangent le fruit de l'oubli et ne veulent plus rentrer — il faut les traîner de force aux navires."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000023")!,
            km: 1000,
            label: "Pays des Cyclopes",
            description: "L'île de Polyphème. La perte de six hommes et de la faveur de Poséidon vont compliquer dix ans de retour."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000024")!,
            km: 1800,
            label: "L'île d'Éole",
            description: "Le dieu des vents offre une outre contenant les vents contraires. Ouverte par les compagnons jaloux, elle renvoie tout le monde au départ."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-00000000002A")!,
            km: 2200,
            label: "Lestrygons",
            description: "Les géants cannibales coulent onze des douze navires. La flotte d'Ulysse est réduite à un seul vaisseau."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-00000000002B")!,
            km: 2600,
            label: "Circé — Aiaié",
            description: "La magicienne de l'île d'Aiaié change l'équipage en pourceaux. Ulysse lui résiste et demeure un an à ses côtés."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000025")!,
            km: 3200,
            label: "Pays des Morts",
            description: "Ulysse descend aux Enfers consulter le devin Tirésias. Il revoit Achille, Ajax et l'ombre de sa propre mère."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-00000000002C")!,
            km: 3800,
            label: "Les Sirènes",
            description: "Ulysse se fait lier au mât pour entendre le chant mortel. Les rameurs, oreilles emplies de cire, forcent le passage."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-00000000002D")!,
            km: 4200,
            label: "Scylla & Charybde",
            description: "Entre le monstre aux six gueules et le tourbillon qui engloutit les navires. Six compagnons sont happés d'un coup."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-00000000002E")!,
            km: 4700,
            label: "Île du Soleil — Thrinacie",
            description: "Malgré l'interdit, les compagnons affamés dévorent les bœufs sacrés d'Hélios. Zeus foudroie le navire ; seul Ulysse survit."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000026")!,
            km: 5500,
            label: "Ogygie — Calypso",
            description: "Sept ans captif sur l'île de la nymphe Calypso. Elle lui offre l'immortalité. Il refuse et choisit Ithaque."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000027")!,
            km: 7200,
            label: "Schérie — les Phéaciens",
            description: "Peuple ami des dieux, les Phéaciens l'écoutent raconter dix ans d'aventures puis le ramènent endormi à Ithaque."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000028")!,
            km: 8000,
            label: "Ithaque",
            description: "L'arrivée en secret, le vieux chien Argos qui reconnaît son maître, et la vengeance des prétendants à l'arc d'ivoire."
        ),
    ]
)

private let journeyIliade = Journey(
    id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000003")!,
    name: "L'Iliade — siège de Troie",
    subtitle: "Mycènes → Troie — 10 ans de siège",
    totalKm: 400,
    category: .myth,
    emoji: "🐴",
    milestones: [
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000031")!,
            km: 0,
            label: "Mycènes",
            description: "Agamemnon rassemble les rois grecs. La flotte de mille navires se forme pour venger l'honneur de Ménélas."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000033")!,
            km: 50,
            label: "Aulis",
            description: "Le port du rassemblement. Pour obtenir des vents favorables, Agamemnon doit sacrifier sa propre fille, Iphigénie."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000034")!,
            km: 150,
            label: "Débarquement en Troade",
            description: "Après la traversée de l'Égée, les Grecs abordent devant Troie. Protésilas, premier à sauter à terre, est le premier à tomber."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000035")!,
            km: 230,
            label: "La colère d'Achille",
            description: "Agamemnon lui prend Briséis. Achille se retire sous sa tente et prive les Grecs de leur plus grand guerrier."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000036")!,
            km: 290,
            label: "Mort de Patrocle",
            description: "Revêtu des armes d'Achille, Patrocle repousse les Troyens mais tombe sous les coups d'Hector. La douleur rappelle Achille au combat."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000037")!,
            km: 340,
            label: "Achille tue Hector",
            description: "Le duel décisif sous les murs. Achille traîne le corps d'Hector autour de la cité avant de le rendre au vieux roi Priam."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000038")!,
            km: 370,
            label: "Le cheval de bois",
            description: "La ruse d'Ulysse : un cheval de bois géant abandonné devant les portes, que les Troyens introduisent eux-mêmes dans la ville."
        ),
        Milestone(
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000032")!,
            km: 400,
            label: "La chute de Troie",
            description: "Dans la nuit, les Grecs sortis du cheval ouvrent les portes. Troie, jugée inexpugnable, s'effondre dans les flammes."
        ),
    ]
)
