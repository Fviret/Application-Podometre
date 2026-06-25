import Foundation

/// Catalogue de tous les trajets disponibles dans l'application.
let allJourneys: [Journey] = [
    journeyParisNice,
    journeyComteMordor
]

// MARK: - Paris → Nice (930 km)

private let journeyParisNice = Journey(
    id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000001")!,
    title: "Paris → Nice",
    subtitle: "930 km à travers la France, du bassin parisien à la Méditerranée.",
    coverImageName: "journey_paris_nice",
    totalKm: 930,
    milestones: [
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000011")!,
            kmFromStart: 77,
            locationName: "Fontainebleau",
            ambiance: "La forêt s'ouvre par plaques, rochers de grès affleurant entre les chênes. L'air sent la résine et la terre humide. Paris est déjà loin, même si on pourrait encore presque en entendre le bruit.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000012")!,
            kmFromStart: 120,
            locationName: "Sens",
            ambiance: "La cathédrale surgit sans prévenir au-dessus des toits bas. L'Yonne longe la ville avec une lenteur de fleuve habitué à attendre. Les rues du centre sont calmes, pavées de cette tranquillité provinciale qui n'appartient qu'aux villes moyennes.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000013")!,
            kmFromStart: 195,
            locationName: "Auxerre",
            ambiance: "Les vignes commencent ici, encore timides, en lisière. La ville descend vers l'Yonne par gradins, façades ocre et toits d'ardoise. Le Chablis pousse à quelques kilomètres dans des sols qui ressemblent à rien mais donnent tout.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000014")!,
            kmFromStart: 390,
            locationName: "Mâcon",
            ambiance: "La Saône est large ici, presque immobile en surface. Les quais ont cette qualité particulière des villes fluviales : un sentiment de passage, d'entre-deux. La Bourgogne cède, la vallée du Rhône commence à souffler.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000015")!,
            kmFromStart: 465,
            locationName: "Lyon",
            ambiance: "Deux fleuves, deux collines, une lumière qui change selon l'heure. La Presqu'île serre ses immeubles comme pour retenir quelque chose. Le soir, les traboules sentent la pierre froide et les cours intérieures gardent leur silence jalousement.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000016")!,
            kmFromStart: 560,
            locationName: "Valence",
            ambiance: "Le vent du sud commence à se faire sentir — pas encore la chaleur sèche, plutôt une promesse. Le Rhône est puissant, brun et décidé. On est à mi-chemin, dans cette zone où ni le nord ni le sud ne revendique vraiment le territoire.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000017")!,
            kmFromStart: 620,
            locationName: "Montélimar",
            ambiance: "Les lavandes n'y sont plus, les amandiers non plus, mais l'odeur sucrée semble imprégnée dans les murs de la vieille ville. Les platanes découpent l'ombre en dalles régulières sur les trottoirs. C'est ici que la Provence commence à prendre forme dans la lumière.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000018")!,
            kmFromStart: 790,
            locationName: "Aix-en-Provence",
            ambiance: "Le cours Mirabeau filtre la lumière à travers les platanes en une sorte de clarté verte et dorée. La Sainte-Victoire est partout — dans les angles de rue, au bout des perspectives. Cézanne avait raison : cette montagne change toutes les heures.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "A1B2C3D4-0001-0001-0001-000000000019")!,
            kmFromStart: 930,
            locationName: "Nice",
            ambiance: "La Méditerranée apparaît d'un coup, entre deux immeubles, bleue d'un bleu qui ne ressemble à aucun autre. La Promenade des Anglais est longue et indifférente. La vieille ville, elle, sent le basilic, la socca et les ruelles trop étroites pour l'été.",
            imageName: nil
        )
    ]
)

// MARK: - La Comté → Mordor (1 779 km)

private let journeyComteMordor = Journey(
    id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000002")!,
    title: "La Comté → Mordor",
    subtitle: "1 779 km à travers la Terre du Milieu, du Bout-des-Terres au Mont Destin.",
    coverImageName: "journey_comte_mordor",
    totalKm: 1779,
    milestones: [
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000021")!,
            kmFromStart: 0,
            locationName: "Hobbitebourg",
            ambiance: "Les collines vertes et rondes du Pays de Bouc s'étendent sous un ciel sans menace. Les chemins creux entre les haies sentent la terre grasse. Rien ici ne laisse présager que quoi que ce soit puisse mal tourner.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000022")!,
            kmFromStart: 180,
            locationName: "Bree",
            ambiance: "La ville est plus grande qu'on ne l'imaginait, plus sombre aussi. Les Grandes Gens et les Petites Gens s'y croisent sans vraiment se regarder. Le Poney Fringant sent la bière éventée et les voyageurs qui n'ont pas envie de parler.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000023")!,
            kmFromStart: 370,
            locationName: "Weathertop",
            ambiance: "La colline ruinée domine les landes dans toutes les directions. Le vent ne s'arrête jamais ici. La nuit, les étoiles sont très claires et très froides, et l'obscurité entre les blocs de pierre effondrée a une consistance qu'on ne trouve nulle part ailleurs.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000024")!,
            kmFromStart: 560,
            locationName: "Rivendell",
            ambiance: "On l'entend avant de la voir — l'eau, partout, sur des pierres qui semblent disposées exprès. La vallée cache Imladris jusqu'au dernier moment. Les salles ouvertes sur le vide sentent la résine et quelque chose d'indéfinissable qui pourrait être du temps accumulé.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000025")!,
            kmFromStart: 780,
            locationName: "La Moria",
            ambiance: "L'obscurité de la Moria n'est pas une absence de lumière — c'est une présence à part entière. Les salles des nains sont si vastes que les pas ne trouvent pas de mur où résonner. On avance en devinant la profondeur plus qu'en la voyant.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000026")!,
            kmFromStart: 950,
            locationName: "Lothlórien",
            ambiance: "Les mallorn ont des feuilles d'or à l'automne et d'argent au printemps, dit-on. Ce qui est certain, c'est que la lumière y filtre différemment — plus lentement, comme si elle aussi voulait rester. Le silence de Caras Galadhon est un silence choisi.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000027")!,
            kmFromStart: 1150,
            locationName: "Les Chutes de Rauros",
            ambiance: "Le grondement précède la vue de plusieurs heures de navigation. L'Anduin s'accélère imperceptiblement avant de basculer. Les statues des Argonath se dressent de chaque côté du fleuve avec l'indifférence absolue de ce qui a été taillé pour durer.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000028")!,
            kmFromStart: 1380,
            locationName: "Henneth Annûn",
            ambiance: "La fenêtre du coucher du soleil ne s'ouvre qu'un instant, une fois le jour. Derrière la cascade, la salle de pierre est fraîche et sèche. Les Rangers d'Ithilien ont tenu ce secret longtemps — on comprend pourquoi quand on voit ce que la forêt dissimule.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000029")!,
            kmFromStart: 1620,
            locationName: "Cirith Ungol",
            ambiance: "Le col est taillé dans une roche qui semble avoir été torturée plutôt que formée. L'air y est épais, chargé d'une odeur que l'on ne nomme pas. La tour au sommet surveille dans les deux sens : ce qui vient de l'ouest autant que ce qui monte de l'est.",
            imageName: nil
        ),
        Milestone(
            id: UUID(uuidString: "B2C3D4E5-0002-0002-0002-000000000030")!,
            kmFromStart: 1779,
            locationName: "Mont Doom",
            ambiance: "La Montagne du Destin ne ressemble pas à une montagne ordinaire — elle pulse, comme quelque chose de vivant. La Crevasse du Destin est en son cœur, accessible par une corniche que les âges ont usée. Ce qui se passe à l'intérieur appartient au feu.",
            imageName: nil
        )
    ]
)
