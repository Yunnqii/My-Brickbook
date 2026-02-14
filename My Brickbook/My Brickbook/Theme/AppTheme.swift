//
//  AppTheme.swift
//  My Brickbook
//
//  Modern soft minimal — iOS 17 + Nordic. Cream, muted sage, no borders, soft shadows.
//

import SwiftUI

enum AppTheme {
    // MARK: - Surfaces
    static let cream = Color(red: 0.995, green: 0.99, blue: 0.975)
    static let creamWarm = Color(red: 0.98, green: 0.97, blue: 0.95)

    // MARK: - Sage (muted green accent)
    static let sage = Color(red: 0.52, green: 0.64, blue: 0.58)
    static let sageMuted = Color(red: 0.62, green: 0.72, blue: 0.66)
    static let sageLight = Color(red: 0.88, green: 0.92, blue: 0.90)
    static let sageSubtle = Color(red: 0.92, green: 0.95, blue: 0.93)

    // MARK: - Text (warm, low contrast)
    static let textPrimary = Color(red: 0.22, green: 0.22, blue: 0.20)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.44)
    static let textTertiary = Color(red: 0.58, green: 0.60, blue: 0.56)

    // MARK: - Shadows (soft only)
    static let shadowSubtle = Color.black.opacity(0.06)
    static let shadowSoft = Color.black.opacity(0.08)
    static let shadowCard = Color(red: 0.4, green: 0.45, blue: 0.42).opacity(0.12)

    // MARK: - Legacy compatibility (map to new palette)
    static var softGreen: Color { sage }
    static var softGreenBorder: Color { sageMuted }
    static var softGreenLight: Color { sageLight }
    static var softGreenMuted: Color { sageMuted }
    static var muted: Color { textTertiary }
    static var cardLockedBorder: Color { Color(red: 0.88, green: 0.88, blue: 0.86) }
    static var cardLockedBg: Color { Color(red: 0.96, green: 0.96, blue: 0.95) }
    static var cardLockedText: Color { textTertiary }
    static var cardLockedAccent: Color { Color(red: 0.78, green: 0.78, blue: 0.76) }
}
