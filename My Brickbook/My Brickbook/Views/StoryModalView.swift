//
//  StoryModalView.swift
//  My Brickbook
//

import SwiftUI

struct StoryModalView: View {
    let story: Story
    let triggerCard: CollectibleCard?
    @Bindable var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("New story unlocked!")
                .font(.caption)
                .foregroundStyle(AppTheme.softGreen)

            Text(story.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(story.text)
                .font(.body)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let card = triggerCard {
                Text("Triggered by: #\(card.number) \(card.name)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Button("Got it!") {
                appState.dismissStoryModal()
                dismiss()
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.softGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(24)
        .background(AppTheme.cream)
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Shared overlay for “story unlocked” (used by AddCardFlowView and CardDetailSheet)

struct StoryUnlockedOverlayView: View {
    let story: Story
    let triggerCard: CollectibleCard?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("🎉 New story unlocked!")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.softGreen)

            Text(story.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(story.text)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let card = triggerCard {
                Text("Triggered by: #\(card.number) \(card.name)")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.muted)
            }

            Button(action: onDone) {
                Text("Got it!")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(AppTheme.softGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(32)
        .frame(maxWidth: 340)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.cream)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}
