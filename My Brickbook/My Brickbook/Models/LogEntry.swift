//
//  LogEntry.swift
//  My Brickbook
//

import Foundation

struct LogEntry: Identifiable, Codable, Equatable {
    let id: String
    let storyId: String
    let triggeredByCardId: String
    let date: Date

    init(id: String = UUID().uuidString, storyId: String, triggeredByCardId: String, date: Date = Date()) {
        self.id = id
        self.storyId = storyId
        self.triggeredByCardId = triggeredByCardId
        self.date = date
    }
}
