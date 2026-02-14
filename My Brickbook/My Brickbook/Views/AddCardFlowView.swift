//
//  AddCardFlowView.swift
//  My Brickbook
//

import SwiftUI

struct AddCardFlowView: View {
    @Bindable var appState: AppState
    @Environment(\.dismiss) private var dismiss
    var initialStep: AddStep = .type
    var initialSelectedType: CardSet = .home

    @State private var step: AddStep
    @State private var selectedType: CardSet
    @State private var searchText = ""
    @State private var storyToPresent: Story?
    @State private var storyTriggerCard: CollectibleCard?

    init(appState: AppState, initialStep: AddStep = .type, initialSelectedType: CardSet = .home) {
        self.appState = appState
        self.initialStep = initialStep
        self.initialSelectedType = initialSelectedType
        _step = State(initialValue: initialStep)
        _selectedType = State(initialValue: initialSelectedType)
    }

    enum AddStep {
        case type
        case pickCard
        case done
    }

    enum CardSet: String, CaseIterable {
        case home = "Home"
        case family = "Family"
    }

    private var filteredCards: [CollectibleCard] {
        let list = selectedType == .home ? appState.homeCards : appState.familyCards
        if searchText.isEmpty { return list }
        let q = searchText.lowercased()
        return list.filter {
            $0.name.lowercased().contains(q) || "\($0.number)".contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .type:
                    typePicker
                case .pickCard:
                    brickPickerScreen
                case .done:
                    EmptyView()
                }
            }
            .id(step)
            .animation(.easeInOut(duration: 0.2), value: step)
            .background(AppTheme.cream)
            .navigationTitle("Add to collection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(step == .pickCard)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step == .pickCard, initialStep == .type {
                        Button("Back") {
                            step = .type
                        }
                        .foregroundStyle(AppTheme.softGreen)
                    } else if step != .pickCard {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundStyle(AppTheme.softGreen)
                    }
                }
            }
        }
        .overlay {
            if let story = storyToPresent {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // 点击背景不关闭
                        }
                    
                    StoryUnlockedOverlayView(
                        story: story,
                        triggerCard: storyTriggerCard,
                        onDone: {
                            storyToPresent = nil
                            storyTriggerCard = nil
                            dismiss()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: storyToPresent != nil)
            }
        }
    }

    private var typePicker: some View {
        VStack(spacing: 24) {
            Text("What did you pull?")
                .font(.title3)
                .foregroundStyle(AppTheme.textPrimary)

            Picker("Type", selection: $selectedType) {
                ForEach(CardSet.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Button {
                step = .pickCard
            } label: {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(AppTheme.softGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()
        }
        .padding(.top, 40)
    }

    private var brickPickerScreen: some View {
        let list = selectedType == .home ? appState.homeCards : appState.familyCards
        let total = list.count
        let collected = list.filter { appState.isOwned($0.id) }.count
        return BrickPickerScreen(
            searchText: $searchText,
            cards: list,
            collectedCount: collected,
            total: total,
            isCollected: { appState.isOwned($0.id) },
            onBack: {
                if initialStep == .type {
                    step = .type
                } else {
                    dismiss()
                }
            },
            onSelectCard: { addCard($0) },
            hideCloseButton: storyToPresent != nil
        )
    }

    private func addCard(_ card: CollectibleCard) {
        let unlocked = appState.addCard(card.id)

        if let first = unlocked.first {
            storyTriggerCard = card
            storyToPresent = first
            return
        }
        if let relatedStory = appState.stories.first(where: { $0.trigger_cards.contains(card.id) }) {
            storyTriggerCard = card
            storyToPresent = relatedStory
            return
        }
        dismiss()
    }
}

struct AddCardRow: View {
    let card: CollectibleCard
    let isOwned: Bool
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(card.number)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softGreen)
                    Spacer()
                }
                Text(card.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)
                if !card.tagline.isEmpty {
                    Text(card.tagline)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }
                Text("Add to my collection")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.softGreen)
                    .padding(.top, 4)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isOwned ? AppTheme.softGreenBorder : AppTheme.muted, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(isOwned ? 0.8 : 1)
    }
}

