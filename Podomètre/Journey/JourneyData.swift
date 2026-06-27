import Foundation

/// Catalogue de tous les trajets disponibles, regroupables par catégorie.
let allJourneys: [Journey] = [
    // Sentiers
    journeyGR20,
    journeyCaminoFinal,
    journeyCaminoComplet,
    journeyViaPlata,
    journeyTMB,
    journeyViaFrancigena,
    // Histoire
    journeyRouteRoyalePerse,
    journeyAlexandrePerse,
    journeyAlexandreComplet,
    journeyRouteSoie,
    journeyMarcoPolo,
    // Mythes & Épopées
    journeyOdysseeReel,
    journeyOdysseeComplet,
    journeyIliade,
]

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
            id: UUID(uuidString: "C3D4E5F6-0001-0001-0001-000000000012")!,
            km: 88,
            label: "Vizzavone",
            description: "Mi-parcours, accessible par le train. La forêt de laricio offre une pause bienvenue après les crêtes exposées."
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
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000022")!,
            km: 22,
            label: "Portomarín",
            description: "Village reconstruit après que l'ancien fut noyé sous le lac de Belesar dans les années 1960."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000023")!,
            km: 48,
            label: "Palas de Rei",
            description: "Nom lié aux rois wisigoths. Étape tranquille à mi-chemin du tronçon final, cœur de la Galice verte."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0002-0002-0002-000000000024")!,
            km: 80,
            label: "Arzúa",
            description: "Capitale du fromage galicien. À une journée de Santiago, les pèlerins sentent déjà la fin du chemin."
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
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000052")!,
            km: 75,
            label: "Courmayeur",
            description: "Côté italien du massif. Village alpin animé au pied du versant sud du Mont Blanc, sous un soleil plus généreux."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0005-0005-0005-000000000053")!,
            km: 120,
            label: "Champex",
            description: "Lac de montagne suisse d'une sérénité absolue, perché à 1 470 mètres entre mélèzes et reflets parfaits."
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
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000062")!,
            km: 80,
            label: "San Gimignano",
            description: "Les tours médiévales surgissent au-dessus des vignes à Vernaccia. Classée au patrimoine mondial de l'Unesco."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000063")!,
            km: 110,
            label: "Sienne",
            description: "Le Palio, la Piazza del Campo en coquille, les couleurs siennées. Joyau de la Toscane médiévale."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000064")!,
            km: 310,
            label: "Viterbe",
            description: "Ancienne résidence des papes au XIIIe siècle, cité médiévale remarquablement conservée dans le Latium."
        ),
        Milestone(
            id: UUID(uuidString: "C3D4E5F6-0006-0006-0006-000000000065")!,
            km: 420,
            label: "Rome",
            description: "La basilique Saint-Pierre au bout du chemin. Le pèlerin arrive dans la Ville Éternelle après des semaines de Toscane."
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
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000012")!,
            km: 700,
            label: "Persépolis",
            description: "Capitale cérémonielle achéménide, où les tributs de l'empire entier affluaient à chaque printemps."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0001-0001-0001-000000000013")!,
            km: 1400,
            label: "Mésopotamie",
            description: "Traversée du cœur de l'empire entre Tigre et Euphrate, berceau des civilisations et grenier du monde perse."
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
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000023")!,
            km: 1100,
            label: "Bataille d'Issos",
            description: "Darius III en fuite, sa famille capturée. L'empire perse commence à vaciller sous les coups macédoniens."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0002-0002-0002-000000000024")!,
            km: 2800,
            label: "Babylone",
            description: "La plus grande ville du monde prise sans combat. Alexandre se présente en libérateur plutôt qu'en conquérant."
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
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000035")!,
            km: 8000,
            label: "Bactres",
            description: "Aux portes de l'Asie centrale, Alexandre épouse Roxane. La résistance bactriène est la plus farouche rencontrée."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000036")!,
            km: 14000,
            label: "Taxila",
            description: "Première grande cité indienne. Le roi Poros attend sur l'Hydaspe avec deux cents éléphants de guerre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0003-0003-0003-000000000037")!,
            km: 17000,
            label: "Rivière Beas",
            description: "La mutinerie. Les soldats refusent d'avancer vers l'Inde profonde. Alexandre pleure dans sa tente, puis accepte de rentrer."
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
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000042")!,
            km: 2000,
            label: "Dunhuang",
            description: "Oasis du désert de Gobi, gardienne des Grottes de Mogao aux mille bouddhas sculptés dans la roche ocre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000043")!,
            km: 3500,
            label: "Samarcande",
            description: "Joyau de l'Asie centrale, carrefour de toutes les caravanes. Tamerlan en fit la capitale de son empire au XIVe siècle."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0004-0004-0004-000000000044")!,
            km: 4500,
            label: "Persépolis",
            description: "L'ancienne capitale perse ruinée par Alexandre, toujours imposante sur le passage des marchands."
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
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000052")!,
            km: 2000,
            label: "Constantinople",
            description: "Première grande escale dans la ville-carrefour de la Méditerranée orientale, centre du commerce mondial."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000053")!,
            km: 5000,
            label: "Ormuz",
            description: "Port du Golfe Persique. Marco vit des navires si fragiles qu'il refusa d'embarquer et continua par voie terrestre."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000054")!,
            km: 7000,
            label: "Kashgar",
            description: "Oasis mythique au pied du Pamir, carrefour des routes vers l'Inde, la Perse et la Chine profonde."
        ),
        Milestone(
            id: UUID(uuidString: "D4E5F6A7-0005-0005-0005-000000000055")!,
            km: 12000,
            label: "Pékin",
            description: "La cour de Kubilaï Khan. Marco Polo y passa dix-sept ans comme gouverneur et émissaire du Grand Khan."
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
            id: UUID(uuidString: "E5F6A7B8-0001-0001-0001-000000000012")!,
            km: 350,
            label: "Cyclopes — Sicile",
            description: "L'île de Polyphème. Ulysse lui crève l'œil avec un pieu d'olivier et s'échappe sous le ventre d'une brebis."
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
            id: UUID(uuidString: "E5F6A7B8-0002-0002-0002-000000000025")!,
            km: 3200,
            label: "Pays des Morts",
            description: "Ulysse descend aux Enfers consulter le devin Tirésias. Il revoit Achille, Ajax et l'ombre de sa propre mère."
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
            id: UUID(uuidString: "E5F6A7B8-0003-0003-0003-000000000032")!,
            km: 400,
            label: "Troie",
            description: "Dix ans de siège. Hector contre Achille, le cheval de bois, la chute de la cité jugée inexpugnable."
        ),
    ]
)
