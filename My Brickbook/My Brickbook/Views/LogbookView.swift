//
//  LogbookView.swift
//  My Brickbook
//
//  Modern soft minimal — floating journal cards, cream + sage, no dividers.
//

import SwiftUI

private enum LogbookStyle {
    static let cream = Color(hex: "F8F5F1")
    static let sage = Color(hex: "7FA68C")
    static let sageSoft = Color(hex: "7FA68C").opacity(0.2)
    static let textPrimary = Color(red: 0.22, green: 0.22, blue: 0.20)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.44)
    static let shadowCard = Color.black.opacity(0.08)
}

struct LogbookView: View {
    @Bindable var appState: AppState
    @State private var searchText = ""
    @State private var filterChip: String? = nil

    private let filterOptions = ["All", "Maya", "Leo", "Finn", "Laura", "Joy", "Pets", "Garden", "Kitchen", "Pantry"]

    private var filteredEntries: [LogEntry] {
        let ownedIds = appState.ownedCardIds
        var entries = appState.logEntries.filter { ownedIds.contains($0.triggeredByCardId) }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            entries = entries.filter { entry in
                guard let story = appState.story(byId: entry.storyId),
                      let card = appState.card(byId: entry.triggeredByCardId) else { return true }
                return story.title.lowercased().contains(q)
                    || story.text.lowercased().contains(q)
                    || card.name.lowercased().contains(q)
            }
        }
        if let chip = filterChip, chip != "All" {
            entries = entries.filter { entry in
                guard let story = appState.story(byId: entry.storyId) else { return true }
                return story.title.lowercased().contains(chip.lowercased())
                    || story.text.lowercased().contains(chip.lowercased())
            }
        }
        return entries
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header (match Collection/Family: uppercase label + editorial line)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Logbook")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.6)

                    Text("A tiny record of your home stories.")
                        .font(.system(size: 28, weight: .light, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 28)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(LogbookStyle.textSecondary.opacity(0.8))
                    TextField("Search by title, character or card", text: $searchText)
                        .font(.system(size: 16, design: .rounded))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filterOptions, id: \.self) { option in
                            LogbookFilterChip(
                                title: option,
                                isSelected: filterChip == option || (filterChip == nil && option == "All")
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    filterChip = option == "All" ? nil : option
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)

                // Entries
                if filteredEntries.isEmpty {
                    ContentUnavailableView(
                        "No stories yet",
                        systemImage: "book.closed",
                        description: Text("Add cards to your collection to unlock little home moments here.")
                    )
                    .foregroundStyle(LogbookStyle.sage.opacity(0.8))
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredEntries) { entry in
                            LogbookEntryCard(entry: entry, appState: appState)
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }
                    }
                    .animation(.easeOut(duration: 0.35), value: filteredEntries.map(\.id))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        .background(LogbookStyle.cream)
    }
}

struct LogbookFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? .white : LogbookStyle.textSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? LogbookStyle.sage : LogbookStyle.sageSoft)
                )
        }
        .buttonStyle(LogbookChipButtonStyle())
    }
}

private struct LogbookChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.sage : AppTheme.sageSubtle)
                .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct LogbookEntryCard: View {
    let entry: LogEntry
    @Bindable var appState: AppState

    private var story: Story? { appState.story(byId: entry.storyId) }
    private var triggerCard: CollectibleCard? { appState.card(byId: entry.triggeredByCardId) }

    private var footerMeta: String {
        var parts: [String] = []
        if let card = triggerCard {
            parts.append(card.name)
        }
        parts.append(entry.date.formatted(date: .abbreviated, time: .omitted))
        return parts.joined(separator: " · ")
    }

    var body: some View {
        Button {
            // Optional: expand or detail
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                if let story = story {
                    Text(story.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(LogbookStyle.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(story.text)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(LogbookStyle.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("From: \(footerMeta)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(LogbookStyle.sage)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .shadow(color: LogbookStyle.shadowCard, radius: 16, x: 0, y: 6)
        }
        .buttonStyle(LogbookCardButtonStyle())
    }
}

private struct LogbookCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
    }
}
