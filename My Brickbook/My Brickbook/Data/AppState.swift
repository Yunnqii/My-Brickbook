//
//  AppState.swift
//  My Brickbook
//

import Foundation
import SwiftUI

@Observable
final class AppState {
    // Loaded once from bundle
    private(set) var cards: [CollectibleCard] = []
    private(set) var stories: [Story] = []

    // 每张卡牌拥有数量，用于角标显示；同时派生 ownedCardIds 供进度与故事引擎用
    private var _ownedCardCounts: [String: Int] = [:] {
        didSet { persistOwnedCounts() }
    }
    private func persistOwnedCounts() {
        guard let data = try? JSONEncoder().encode(_ownedCardCounts) else { return }
        UserDefaults.standard.set(data, forKey: "ownedCardCounts")
    }

    var ownedCardIds: Set<String> {
        Set(_ownedCardCounts.filter { $0.value > 0 }.map(\.key))
    }

    private var _unlockedStoryIds: [String] = []
    var unlockedStoryIds: Set<String> {
        get { Set(_unlockedStoryIds) }
        set {
            _unlockedStoryIds = Array(newValue)
            UserDefaults.standard.set(_unlockedStoryIds, forKey: "unlockedStoryIds")
        }
    }

    private var _logEntries: [LogEntry] = []
    var logEntries: [LogEntry] {
        get { _logEntries }
        set {
            _logEntries = newValue
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "logEntries")
            }
        }
    }

    // Story to show in modal (nil = hide)
    var storyToPresent: Story?

    /// Set when a story is unlocked during add flow; present after picker sheet dismisses.
    var pendingStoryToPresent: Story?

    init() {
        cards = DataLoader.loadCollectibles()
        stories = DataLoader.loadStories()
        if let data = UserDefaults.standard.data(forKey: "ownedCardCounts"),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            _ownedCardCounts = decoded
        } else if let legacy = UserDefaults.standard.stringArray(forKey: "ownedCardIds") {
            _ownedCardCounts = Dictionary(uniqueKeysWithValues: Set(legacy).map { ($0, 1) })
        }
        _unlockedStoryIds = UserDefaults.standard.stringArray(forKey: "unlockedStoryIds") ?? []
        if let data = UserDefaults.standard.data(forKey: "logEntries"),
           let decoded = try? JSONDecoder().decode([LogEntry].self, from: data) {
            _logEntries = decoded
        }
        // Keep log entries only for cards still owned (sync with Collection/Family)
        let owned = ownedCardIds
        let validEntries = _logEntries.filter { owned.contains($0.triggeredByCardId) }
        if validEntries.count != _logEntries.count {
            logEntries = validEntries
        }
    }

    /// 当前拥有该卡牌的数量（用于角标显示）
    func ownedCount(for cardId: String) -> Int {
        _ownedCardCounts[cardId] ?? 0
    }

    var homeCards: [CollectibleCard] {
        cards.filter { $0.isHome }
    }

    var familyCards: [CollectibleCard] {
        cards.filter { $0.isFamily }
    }

    func isOwned(_ cardId: String) -> Bool {
        ownedCardIds.contains(cardId)
    }

    func card(byId id: String) -> CollectibleCard? {
        cards.first { $0.id == id }
    }

    func story(byId id: String) -> Story? {
        stories.first { $0.id == id }
    }

    /// Add a card to collection. Only runs story engine when this is the *first* time owning the card (no duplicate triggers).
    func addCard(_ cardId: String) -> [Story] {
        let previousCount = _ownedCardCounts[cardId] ?? 0
        _ownedCardCounts[cardId] = previousCount + 1
        let wasAlreadyOwned = previousCount > 0
        let newOwned = ownedCardIds

        if wasAlreadyOwned {
            return []
        }

        var newlyUnlocked: [Story] = []
        var newUnlocked = unlockedStoryIds
        var entries = logEntries

        for story in stories where story.trigger_cards.contains(cardId) {
            guard !newUnlocked.contains(story.id) else { continue }
            let allRequiredOwned = story.required_before.allSatisfy { newOwned.contains($0) }
            if allRequiredOwned {
                newUnlocked.insert(story.id)
                entries.insert(LogEntry(storyId: story.id, triggeredByCardId: cardId, date: Date()), at: 0)
                newlyUnlocked.append(story)
            }
        }

        unlockedStoryIds = newUnlocked
        logEntries = entries
        return newlyUnlocked
    }

    func removeCard(_ cardId: String) {
        let current = _ownedCardCounts[cardId] ?? 0
        if current <= 1 {
            _ownedCardCounts.removeValue(forKey: cardId)
            // When card is fully removed, clear any Logbook entries triggered by this card
            logEntries = logEntries.filter { $0.triggeredByCardId != cardId }
        } else {
            _ownedCardCounts[cardId] = current - 1
        }
    }

    func dismissStoryModal() {
        storyToPresent = nil
    }

    func presentStory(_ story: Story) {
        storyToPresent = story
    }

    func logEntry(for storyId: String) -> LogEntry? {
        logEntries.first { $0.storyId == storyId }
    }

    /// Ensure a log entry exists when we show the story overlay (e.g. fallback “related” story), so it appears in Logbook.
    func ensureLogEntry(storyId: String, triggeredByCardId: String) {
        guard logEntries.first(where: { $0.storyId == storyId }) == nil else { return }
        var entries = logEntries
        entries.insert(LogEntry(storyId: storyId, triggeredByCardId: triggeredByCardId, date: Date()), at: 0)
        logEntries = entries
    }
}
