//
//  CollectibleCard.swift
//  My Brickbook
//

import Foundation

struct CollectibleCard: Identifiable, Codable {
    let id: String
    let set: String  // "family" | "home"
    let number: Int
    let name: String
    let tagline: String

    var isFamily: Bool { self.set == "family" }
    var isHome: Bool { self.set == "home" }
}

struct CollectiblesBundle: Codable {
    let version: String
    let collection_name: String
    let cards: [CollectibleCard]
}
