//
//  CardDetailSheet.swift
//  My Brickbook
//
//  Premium card detail — hero, embossed badge, floating card, warm CTA.
//

import SwiftUI

// MARK: - Detail theme

private enum DetailTheme {
    static let cream = AppTheme.cream
    static let paleSage = Color(red: 0.92, green: 0.96, blue: 0.93)
    static let sageLight = AppTheme.sageLight
    static let sage = AppTheme.sage
    static let sageMuted = AppTheme.sageMuted
    static let sageDeeper = Color(red: 0.42, green: 0.55, blue: 0.48)
    static let textPrimary = AppTheme.textPrimary
    static let textSecondary = AppTheme.textSecondary
    static let shadowSoft = Color.black.opacity(0.08)
    static let shadowCard = Color.black.opacity(0.06)
}

// MARK: - Hero (single enlarged card with image, no outer panel)

private struct DetailHeroView: View {
    let iconName: String
    var customImageName: String? = nil

    var body: some View {
        DetailIconBadge(iconName: iconName, customImageName: customImageName)
            .padding(.top, 20)
            .padding(.bottom, 24)
    }
}

// MARK: - Icon badge (enlarged 160pt card; image has inner gap, same style for all)

private struct DetailIconBadge: View {
    static let badgeSize: CGFloat = 176
    static let cornerRadius: CGFloat = 34
    static let imageInset: CGFloat = 2

    let iconName: String
    var customImageName: String? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [DetailTheme.sageLight, DetailTheme.sageLight.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
                .shadow(color: DetailTheme.sageMuted.opacity(0.4), radius: 12, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.7), radius: 1, x: -0.5, y: -0.5)

            if let name = customImageName {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: Self.badgeSize - Self.imageInset * 2, maxHeight: Self.badgeSize - Self.imageInset * 2)
                    .padding(Self.imageInset)
                    .frame(width: Self.badgeSize, height: Self.badgeSize)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(DetailTheme.sageMuted)
            }
        }
        .frame(width: Self.badgeSize, height: Self.badgeSize)
    }
}

// MARK: - Title stack (chip + title + subtitle)

private struct DetailTitleStack: View {
    let card: CollectibleCard
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("#\(card.number)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DetailTheme.sageMuted)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(DetailTheme.sageLight.opacity(0.8)))

            Text(card.name)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(DetailTheme.textPrimary)

            if let sub = subtitle, !sub.isEmpty {
                Text(sub)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(DetailTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Floating info card (number + owned count)

private struct DetailFloatingCard: View {
    let cardNumber: Int
    let ownedCount: Int

    var body: some View {
        HStack(spacing: 20) {
            Text("#\(cardNumber)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(DetailTheme.sageMuted)

            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                Text("Owned · \(ownedCount)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundStyle(DetailTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: DetailTheme.shadowCard, radius: 16, x: 0, y: 6)
        )
    }
}

// MARK: - Primary CTA (Bring it home / Already in your home)

private struct DetailPrimaryCTA: View {
    let isOwned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(isOwned ? "✓ Already in your home" : "Bring it home")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                if !isOwned {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(isOwned ? DetailTheme.sageMuted : .white)
            .background(
                Group {
                    if isOwned {
                        RoundedRectangle(cornerRadius: 27)
                            .stroke(DetailTheme.sageMuted, lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(DetailTheme.sageLight.opacity(0.3))
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 27)
                            .fill(
                                LinearGradient(
                                    colors: [DetailTheme.sageMuted, DetailTheme.sageDeeper],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            )
        }
        .buttonStyle(DetailCTAButtonStyle(isOwned: isOwned))
    }
}

private struct DetailCTAButtonStyle: ButtonStyle {
    let isOwned: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !isOwned ? 0.98 : 1)
            .shadow(
                color: isOwned ? .clear : DetailTheme.shadowSoft,
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - CardDetailSheet

struct CardDetailSheet: View {
    let card: CollectibleCard
    @Bindable var appState: AppState
    var onStoryUnlocked: ((Story, CollectibleCard) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DetailHeroView(iconName: iconName(for: card), customImageName: cardImageName(for: card))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 20) {
                        DetailTitleStack(
                            card: card,
                            subtitle: !card.tagline.isEmpty ? card.tagline : (card.isFamily ? familyBio(for: card.name) : nil)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        DetailFloatingCard(
                            cardNumber: card.number,
                            ownedCount: appState.ownedCount(for: card.id)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        DetailPrimaryCTA(isOwned: appState.isOwned(card.id)) {
                            if appState.isOwned(card.id) {
                                appState.removeCard(card.id)
                                dismiss()
                            } else {
                                markAsOwnedAndMaybeShowStory()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)
            .background(DetailTheme.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(DetailTheme.sage)
                }
            }
        }
    }

    private func markAsOwnedAndMaybeShowStory() {
        let unlocked = appState.addCard(card.id)
        if let first = unlocked.first {
            onStoryUnlocked?(first, card)
            dismiss()
            return
        }
        if let relatedStory = appState.stories.first(where: { $0.trigger_cards.contains(card.id) }) {
            appState.ensureLogEntry(storyId: relatedStory.id, triggeredByCardId: card.id)
            onStoryUnlocked?(relatedStory, card)
            dismiss()
            return
        }
        dismiss()
    }

    private func cardImageName(for card: CollectibleCard) -> String? {
        if card.isFamily, (1...8).contains(card.number) { return "Person\(card.number)" }
        if card.isHome, (9...40).contains(card.number) { return "Card\(card.number)" }
        return nil
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
        case 33, 34: return "sparkles"
        case 35: return "fork.knife"
        case 36: return "carrot.fill"
        case 37: return "cart.fill"
        case 38: return "bowl.fill"
        case 39: return "dog.fill"
        case 40: return "leaf.fill"
        default: return "square.fill"
        }
    }

    private func familyBio(for name: String) -> String? {
        switch name {
        case "Maya": return "Mum — loves stargazing, gardening, and a good cuppa. The explorer of the house."
        case "Leo": return "Dad — head chef and vibe manager. Karaoke in the car, BBQ on the weekend."
        case "Finn": return "Son — space-obsessed, official taste-tester for baking. Asks the best questions."
        case "Laura": return "Daughter — cricket dreams and drum practice. Sport and music, no stereotypes."
        case "Olive": return "Baby — tiny hype queen. Drops food, cheers at game day, triggers the best moments."
        case "Joy": return "Grandma — runs the house like ops: first aid, groceries, cleaning. The calm PM."
        case "Woofa": return "Dog — garden patrol and kitchen crumb radar. One bark, full report."
        case "Whiskers": return "Cat — castle queen and evening cuddles. Approves with a slow blink."
        default: return nil
        }
    }
}
