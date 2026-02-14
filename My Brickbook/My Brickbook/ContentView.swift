//
//  ContentView.swift
//  My Brickbook
//
//  Custom shell: floating capsule tab bar, no system TabView.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    @State private var selectedTab = 0
    @State private var showAddModal = false
    @State private var showCardPickerSheet = false
    @State private var cardPickerType: AddCardFlowView.CardSet = .home
    @State private var collectionStoryOverlayVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        CollectionGridView(
                            appState: appState,
                            cards: appState.homeCards,
                            title: "Collection",
                            progressText: "Collected \(appState.ownedCardIds.filter { appState.card(byId: $0)?.isHome == true }.count) / 40",
                            storyOverlayVisible: $collectionStoryOverlayVisible
                        )
                        .toolbar {
                            if !collectionStoryOverlayVisible {
                                ToolbarItem(placement: .primaryAction) {
                                    Button { showAddModal = true } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(AppTheme.sage)
                                    }
                                }
                            }
                        }
                        .toolbarBackground(.hidden, for: .navigationBar)
                    }

                case 1:
                    NavigationStack {
                        CollectionGridView(
                            appState: appState,
                            cards: appState.familyCards,
                            title: "Family",
                            progressText: "Collected \(appState.ownedCardIds.filter { appState.card(byId: $0)?.isFamily == true }.count) / 8"
                        )
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button { showAddModal = true } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(AppTheme.sage)
                                }
                            }
                        }
                        .toolbarBackground(.hidden, for: .navigationBar)
                    }

                case 2:
                    NavigationStack {
                        LogbookView(appState: appState)
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    Button { showAddModal = true } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(AppTheme.sage)
                                    }
                                }
                            }
                            .toolbarBackground(.hidden, for: .navigationBar)
                    }

                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingCapsuleTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 28)
        }
        .ignoresSafeArea(.keyboard)
        .overlay {
            if showAddModal {
                AddCardFloatingOverlay(
                    isPresented: $showAddModal,
                    onContinueToPicker: { type in
                        showAddModal = false
                        cardPickerType = type
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showCardPickerSheet = true
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showCardPickerSheet, onDismiss: {
            guard let pending = appState.pendingStoryToPresent else { return }
            appState.pendingStoryToPresent = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                appState.storyToPresent = pending
            }
        }) {
            AddCardFlowView(
                appState: appState,
                initialStep: .pickCard,
                initialSelectedType: cardPickerType
            )
        }
        .sheet(item: $appState.storyToPresent) { story in
            StoryModalView(
                story: story,
                triggerCard: appState.logEntries.first { $0.storyId == story.id }.flatMap { appState.card(byId: $0.triggeredByCardId) },
                appState: appState
            )
            .onDisappear {
                appState.dismissStoryModal()
            }
        }
    }
}

#Preview {
    ContentView()
}
