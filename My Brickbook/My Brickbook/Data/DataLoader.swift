//
//  DataLoader.swift
//  My Brickbook
//

import Foundation

enum DataLoader {
    static func loadCollectibles() -> [CollectibleCard] {
        guard let url = Bundle.main.url(forResource: "collectibles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bundle = try? JSONDecoder().decode(CollectiblesBundle.self, from: data) else {
            return []
        }
        return bundle.cards
    }

    static func loadStories() -> [Story] {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bundle = try? JSONDecoder().decode(StoriesBundle.self, from: data) else {
            return []
        }
        return bundle.stories
    }
}
