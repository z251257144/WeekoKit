//
//  WeekoThemeEnvironment.swift
//  WeekoKit
//
//  Theme environment key and modifiers
//

import SwiftUI

// MARK: - Theme Environment Key

private struct WeekoThemeKey: EnvironmentKey {
    static let defaultValue: WeekoTheme = WeekoDefaultDarkTheme()
}

extension EnvironmentValues {
    /// Current WeekoKit theme
    public var weekoTheme: WeekoTheme {
        get { self[WeekoThemeKey.self] }
        set { self[WeekoThemeKey.self] = newValue }
    }
}

// MARK: - Theme Modifier

public extension View {
    /// Apply a WeekoKit theme to this view and its descendants
    /// - Parameter theme: The theme to apply
    func weekoTheme(_ theme: WeekoTheme) -> some View {
        environment(\.weekoTheme, theme)
    }
}
