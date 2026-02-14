//
//  FloatingCapsuleTabBar.swift
//  My Brickbook
//
//  Floating pill tab bar — no system TabView, soft shadow, rounded geometry.
//

import SwiftUI

struct FloatingCapsuleTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(title: String, icon: String)] = [
        ("Collection", "square.grid.2x2"),
        ("Family", "person.2.fill"),
        ("Logbook", "book.closed")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    selectedTab = index
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: selectedTab == index ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .medium, design: .rounded))
                    }
                    .foregroundStyle(selectedTab == index ? AppTheme.sage : AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(AppTheme.cream)
                .shadow(color: AppTheme.shadowSoft, radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 24)
    }
}
