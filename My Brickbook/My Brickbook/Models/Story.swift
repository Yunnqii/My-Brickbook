//
//  Story.swift
//  My Brickbook
//

import Foundation

struct Story: Identifiable, Codable {
    let id: String
    let trigger_cards: [String]
    let required_before: [String]
    let title: String
    let text: String
}

struct StoriesBundle: Codable {
    let version: String
    let stories: [Story]
}
