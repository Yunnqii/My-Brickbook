//
//  FloatingCardModal.swift
//  My Brickbook
//
//  Floating card modal: soft minimal, centered overlay, two-layer shadow.
//  Reusable: FloatingModalOverlay, FloatingCardModal, PickTypeCard, PrimaryCapsuleButton.
//

import SwiftUI

// MARK: - Modal palette (floating add flow)
private enum ModalTheme {
    static let cream = Color(hex: "F7F4EF")
    static let sage = Color(hex: "8FAF9C")
    static let strokeUnselected = Color(hex: "E9E5DD")
    static let selectedTint = Color(hex: "E7F1EA")
    static let dim = Color.black.opacity(0.18)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - FloatingModalOverlay

struct FloatingModalOverlay<Content: View>: View {
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            content()
        }
    }
}

// MARK: - FloatingCardModal

struct FloatingCardModal<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(ModalTheme.cream)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 32)
    }
}

// MARK: - PickTypeCard

struct PickTypeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(isSelected ? ModalTheme.sage : Color.primary.opacity(0.6))
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? ModalTheme.selectedTint : .white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(ModalTheme.strokeUnselected, lineWidth: isSelected ? 0 : 1)
                        )
                        .shadow(
                            color: isSelected ? Color.black.opacity(0.08) : .clear,
                            radius: isSelected ? 12 : 0,
                            x: 0,
                            y: 4
                        )
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(ModalTheme.sage)
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - PrimaryCapsuleButton

struct PrimaryCapsuleButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(isEnabled ? .white : Color.primary.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .disabled(!isEnabled)
        .background(
            Capsule()
                .fill(isEnabled ? ModalTheme.sage : ModalTheme.strokeUnselected)
        )
        .buttonStyle(ScaleDownButtonStyle())
    }
}

private struct ScaleDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Add card type (step 1)

enum AddCardModalType: String, CaseIterable {
    case home
    case family
}

// MARK: - Add Card Type Picker Modal (step 1 content)

struct AddCardTypePickerModalContent: View {
    @Binding var selectedType: AddCardModalType?
    let onContinue: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: label + close
            HStack {
                Text("Add a new brick")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(Circle().stroke(ModalTheme.strokeUnselected, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            // Main title
            Text("What did you pull?")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.top, 20)

            // Two selectable cards
            HStack(spacing: 14) {
                PickTypeCard(
                    icon: "house.fill",
                    title: "Home",
                    subtitle: "40 bricks",
                    isSelected: selectedType == .home
                ) { selectedType = .home }

                PickTypeCard(
                    icon: "person.2.fill",
                    title: "Family",
                    subtitle: "8 characters",
                    isSelected: selectedType == .family
                ) { selectedType = .family }
            }
            .padding(.top, 24)

            // CTA
            PrimaryCapsuleButton(
                title: "Continue →",
                isEnabled: selectedType != nil,
                action: onContinue
            )
            .padding(.top, 28)
        }
    }
}

// MARK: - Add Card Overlay (step 1: floating modal with animation)

struct AddCardFloatingOverlay: View {
    @Binding var isPresented: Bool
    let onContinueToPicker: (AddCardFlowView.CardSet) -> Void

    @State private var selectedType: AddCardModalType?
    @State private var modalAppeared = false

    var body: some View {
        FloatingModalOverlay(onDismiss: { isPresented = false }) {
            FloatingCardModal {
                AddCardTypePickerModalContent(
                    selectedType: $selectedType,
                    onContinue: {
                        guard let t = selectedType else { return }
                        let cardSet: AddCardFlowView.CardSet = t == .home ? .home : .family
                        onContinueToPicker(cardSet)
                        isPresented = false
                    },
                    onClose: { isPresented = false }
                )
            }
            .scaleEffect(modalAppeared ? 1 : 0.95)
            .opacity(modalAppeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                modalAppeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Floating Add Modal") {
    ZStack {
        CollectionGridView(
            appState: AppState(),
            cards: DataLoader.loadCollectibles().filter { $0.isHome },
            title: "Collection",
            progressText: "Collected 0 / 40"
        )
        .opacity(0.6)

        AddCardFloatingOverlay(
            isPresented: .constant(true),
            onContinueToPicker: { _ in }
        )
    }
}
