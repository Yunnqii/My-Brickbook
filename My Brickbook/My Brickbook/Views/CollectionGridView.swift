//
//  CollectionGridView.swift
//  My Brickbook
//
//  Modern soft minimal — hero header, 3-column grid, borderless cards, soft shadows on collected only.
//

import SwiftUI

struct CollectionGridView: View {
    @Bindable var appState: AppState
    @State private var selectedCard: CollectibleCard?
    @State private var storyToShow: Story?
    @State private var storyTriggerCard: CollectibleCard?
    let cards: [CollectibleCard]
    let title: String
    let progressText: String
    var storyOverlayVisible: Binding<Bool>?

    private let columns = Array(repeating: GridItem(.flexible(minimum: 96), spacing: 16), count: 3)

    init(
        appState: AppState,
        cards: [CollectibleCard],
        title: String,
        progressText: String,
        storyOverlayVisible: Binding<Bool>? = nil
    ) {
        self.appState = appState
        self.cards = cards
        self.title = title
        self.progressText = progressText
        self.storyOverlayVisible = storyOverlayVisible
        _selectedCard = State(initialValue: nil)
        _storyToShow = State(initialValue: nil)
        _storyTriggerCard = State(initialValue: nil)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero header: small title + editorial progress
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.6)

                    Text(progressText)
                        .font(.system(size: 28, weight: .light, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 28)

                // Grid: large airy spacing, 3 columns
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(cards) { card in
                        CardGridCell(
                            card: card,
                            isOwned: appState.isOwned(card.id),
                            ownedCount: appState.ownedCount(for: card.id)
                        ) {
                            selectedCard = card
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.cream)
        .sheet(item: $selectedCard) { card in
            CardDetailSheet(
                card: card,
                appState: appState,
                onStoryUnlocked: { story, triggerCard in
                    storyToShow = story
                    storyTriggerCard = triggerCard
                    storyOverlayVisible?.wrappedValue = true
                }
            )
        }
        .overlay {
            if let story = storyToShow {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    StoryUnlockedOverlayView(
                        story: story,
                        triggerCard: storyTriggerCard,
                        onDone: {
                            storyToShow = nil
                            storyTriggerCard = nil
                            storyOverlayVisible?.wrappedValue = false
                        }
                    )
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: storyToShow != nil)
            }
        }
    }
}

struct CardGridCell: View {
    let card: CollectibleCard
    let isOwned: Bool
    let ownedCount: Int
    let action: () -> Void

    private let textBlockHeight: CGFloat = 44

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .topLeading) {
                        // Card face: no border; filled shape only
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isOwned ? AppTheme.sageSubtle : AppTheme.creamWarm)
                            .overlay(
                                Group {
                                    if isOwned {
                                        cardIcon
                                    } else {
                                        Text("?")
                                            .font(.system(size: 26, weight: .light, design: .rounded))
                                            .foregroundStyle(AppTheme.cardLockedAccent)
                                    }
                                }
                            )
                            .aspectRatio(1, contentMode: .fit)
                            .layoutPriority(1)
                            .shadow(
                                color: isOwned ? AppTheme.shadowCard : .clear,
                                radius: isOwned ? 12 : 0,
                                x: 0,
                                y: 4
                            )

                        // Count badge (top-left), no border
                        if ownedCount > 0 {
                            Text("\(ownedCount)")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.sage)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Capsule().fill(AppTheme.cream))
                                .shadow(color: AppTheme.shadowSubtle, radius: 4, x: 0, y: 2)
                                .padding(8)
                        }
                    }

                    // Card number (top-right), soft pill
                    Text("\(card.number)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(isOwned ? AppTheme.sage : AppTheme.textTertiary)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(AppTheme.cream))
                        .shadow(color: AppTheme.shadowSubtle, radius: 2, x: 0, y: 1)
                        .padding(8)
                }
                .frame(maxWidth: .infinity)

                // Editorial typography: name + tagline
                VStack(spacing: 2) {
                    Text(card.name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(isOwned ? AppTheme.textPrimary : AppTheme.cardLockedText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.88)

                    if !card.tagline.isEmpty {
                        Text(card.tagline)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(isOwned ? AppTheme.textSecondary : AppTheme.cardLockedAccent)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.9)
                    }
                }
                .frame(height: textBlockHeight)
                .frame(maxWidth: .infinity)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .opacity(isOwned ? 1 : 0.62)
    }

    @ViewBuilder
    private var cardIcon: some View {
        Group {
            if card.number == 9 {
                Image("Microwave")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(systemName: iconName(for: card))
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(AppTheme.sage)
            }
        }
    }

    private func iconName(for card: CollectibleCard) -> String {
        if card.isFamily {
            switch card.name {
            case "Maya": return "star.circle.fill"
            case "Leo": return "flame.fill"
            case "Finn": return "sparkles"
            case "Laura": return "sportscourt.fill"
            case "Olive": return "heart.fill"
            case "Joy": return "leaf.fill"
            case "Woofa": return "pawprint.fill"
            case "Whiskers": return "cat.fill"
            default: return "person.fill"
            }
        }
        switch card.number {
        case 9: return "microwave"
        case 10: return "cup.and.saucer.fill"
        case 11: return "cup.and.saucer.fill"
        case 12: return "toast"
        case 13: return "fork.knife"
        case 14: return "frying.pan.fill"
        case 15: return "apple.logo"
        case 16: return "carrot.fill"
        case 17: return "leaf.fill"
        case 18: return "camera.macro"
        case 19: return "cross.case.fill"
        case 20, 21: return "table.furniture"
        case 22: return "fence.vertical"
        case 23, 24: return "tree.fill"
        case 25: return "leaf.circle.fill"
        case 26: return "teddybear.fill"
        case 27: return "trash.fill"
        case 28: return "leaf.arrow.circlepath"
        case 29: return "sun.max.fill"
        case 30: return "sportscourt.fill"
        case 31: return "refrigerator.fill"
        case 32: return "birthday.cake.fill"
        case 33: return "sparkles"
        case 34: return "sparkles"
        case 35: return "fork.knife"
        case 36: return "carrot.fill"
        case 37: return "cart.fill"
        case 38: return "bowl.fill"
        case 39: return "dog.fill"
        case 40: return "leaf.fill"
        default: return "square.fill"
        }
    }
}

#Preview {
    CollectionGridView(
        appState: AppState(),
        cards: DataLoader.loadCollectibles().filter { $0.isHome },
        title: "Collection",
        progressText: "Collected 0 / 40",
        storyOverlayVisible: nil
    )
}
