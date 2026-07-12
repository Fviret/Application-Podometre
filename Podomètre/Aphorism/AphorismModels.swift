import Foundation

/// Conteneur racine décodé depuis `aphorisms_humor_400.json`.
struct AphorismData: Codable {
    let metadata: AphorismMetadata
    let aphorisms: [Aphorism]
}

/// Métadonnées du recueil d'aphorismes (sous-ensemble des champs du JSON).
struct AphorismMetadata: Codable {
    let total_count: Int
    let language: String
    let license: String
}

/// Un aphorisme unitaire. `year` est optionnel (souvent `null` dans la source).
struct Aphorism: Codable, Identifiable {
    let id: Int
    let text: String
    let author: String
    let category: String
    let tone: String
    let year: Int?
    let source: String
}
