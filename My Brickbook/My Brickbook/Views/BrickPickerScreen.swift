//
//  BrickPickerScreen.swift
//  My Brickbook
//
//  Continue destination: hero header, search, brick grid. Modern minimal, cream + sage.
//

import SwiftUI

// MARK: - Design tokens

private enum PickerTheme {
    static let cream = Color(hex: "F7F4EF")
    static let creamWarm = Color(hex: "F3F4EF")
    static let sage = Color(hex: "8FAF9C")
    static let selectedTint = Color(hex: "E7F1EA")
    static let textPrimary = Color(red: 0.12, green: 0.12, blue: 0.10)
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.42)
    static let shadowSoft = Color.black.opacity(0.06)
    static let shadowCard = Color.black.opacity(0.08)
    static let whiteGlow = Color.white.opacity(0.35)
}

// MARK: - Add to Collection Header (compact)

struct AddToCollectionHeaderView: View {
    let collected: Int
    let total: Int
    let onBack: () -> Void
    var hideCloseButton: Bool = false

    var body: some View {
        HStack {
            if hideCloseButton {
                Color.clear
                    .frame(width: 28, height: 28)
            } else {
                Button(action: onBack) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(PickerTheme.sage.opacity(0.9))
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)

            Text("Collected \(collected)/\(total)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(PickerTheme.sage)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(PickerTheme.selectedTint.opacity(0.9)))
        }
    }
}

// MARK: - SearchBarView

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search by name or number…"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(PickerTheme.textSecondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular, design: .rounded))

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(PickerTheme.textSecondary.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(PickerTheme.selectedTint.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

// MARK: - BrickCardView

struct BrickCardView: View {
    let card: CollectibleCard
    let isCollected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    ZStack(alignment: .topTrailing) {
                        // Center: icon
                        Group {
                            if card.number == 9 {
                                Image("Microwave")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            } else {
                                Image(systemName: iconName(for: card))
                                    .font(.system(size: 28, weight: .light))
                                    .foregroundStyle(isCollected ? PickerTheme.sage : PickerTheme.sage.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)

                        // Top-right: checkmark when collected
                        if isCollected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(PickerTheme.sage)
                                .padding(10)
                        }
                    }

                    // Top-left: number capsule
                    Text("\(card.number)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(PickerTheme.sage)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(PickerTheme.selectedTint.opacity(0.9)))
                        .padding(10)
                }

                Text(card.name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(PickerTheme.textPrimary)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                if !card.tagline.isEmpty {
                    Text(card.tagline)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(PickerTheme.textSecondary)
                        .lineLimit(2)
                        .padding(.horizontal, 12)
                        .padding(.top, 2)
                }

                Spacer(minLength: 8)

                Text(isCollected ? "Collected" : "+ Add")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(isCollected ? PickerTheme.sage : PickerTheme.sage)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        isCollected
                            ? PickerTheme.selectedTint.opacity(0.85)
                            : PickerTheme.selectedTint.opacity(0.5)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: PickerTheme.shadowCard, radius: 8, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(BrickCardButtonStyle(isPressed: $isPressed))
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
}

private struct BrickCardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
            .onAppear { isPressed = configuration.isPressed }
    }
}

// MARK: - BrickPickerScreen

struct BrickPickerScreen: View {
    @Binding var searchText: String
    let cards: [CollectibleCard]
    let collectedCount: Int
    let total: Int
    let isCollected: (CollectibleCard) -> Bool
    let onBack: () -> Void
    let onSelectCard: (CollectibleCard) -> Void
    var hideCloseButton: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var filteredCards: [CollectibleCard] {
        if searchText.isEmpty { return cards }
        let q = searchText.lowercased()
        return cards.filter {
            $0.name.lowercased().contains(q) || "\($0.number)".contains(q)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Modal container: 30pt radius, 24pt padding, cream gradient, shadow
                VStack(alignment: .leading, spacing: 0) {
                    AddToCollectionHeaderView(collected: collectedCount, total: total, onBack: onBack, hideCloseButton: hideCloseButton)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Which brick joined your home?")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(PickerTheme.textPrimary)
                        Text("Tap a brick to collect it.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(PickerTheme.textSecondary)
                    }
                    .padding(.top, 12)

                    SearchBarView(text: $searchText)
                        .padding(.top, 16)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredCards) { card in
                            BrickCardView(
                                card: card,
                                isCollected: isCollected(card),
                                onTap: { onSelectCard(card) }
                            )
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [PickerTheme.creamWarm, PickerTheme.cream],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 32, x: 0, y: 12)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .background(PickerTheme.cream)
    }
}

// MARK: - Preview

#Preview("Brick Picker Screen") {
    BrickPickerScreen(
        searchText: .constant(""),
        cards: DataLoader.loadCollectibles().filter { $0.isHome },
        collectedCount: 12,
        total: 40,
        isCollected: { _ in false },
        onBack: {},
        onSelectCard: { _ in }
    )
}
