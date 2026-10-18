//
//  WeekoAdaptiveTheme.swift
//  WeekoKit
//
//  Adaptive theme that responds to accessibility settings
//

import SwiftUI

/// A theme wrapper that adapts based on system accessibility preferences
public struct WeekoAdaptiveTheme: WeekoTheme {
    
    private let baseTheme: WeekoTheme
    private let accessibility: WeekoAccessibilityObserver
    
    public init(baseTheme: WeekoTheme, accessibility: WeekoAccessibilityObserver) {
        self.baseTheme = baseTheme
        self.accessibility = accessibility
    }
    
    // MARK: - Surface Colors
    
    public var surfaceBackground: Color {
        baseTheme.surfaceBackground
    }
    
    public var surfaceRaised: Color {
        if accessibility.prefersIncreasedContrast {
            // Increase contrast between surfaces
            return adjustContrast(baseTheme.surfaceRaised, by: 0.1)
        }
        return baseTheme.surfaceRaised
    }
    
    public var surfaceOverlay: Color {
        if accessibility.prefersReducedTransparency {
            // Use opaque colors instead of transparent
            return baseTheme.surfaceOverlay
        }
        return baseTheme.surfaceOverlay
    }
    
    public var surfaceElevated: Color {
        baseTheme.surfaceElevated
    }
    
    // MARK: - Content Colors
    
    public var contentPrimary: Color {
        if accessibility.prefersIncreasedContrast {
            // Maximum contrast for primary content
            return .white
        }
        return baseTheme.contentPrimary
    }
    
    public var contentSecondary: Color {
        if accessibility.prefersIncreasedContrast {
            return adjustContrast(baseTheme.contentSecondary, by: 0.15)
        }
        return baseTheme.contentSecondary
    }
    
    public var contentTertiary: Color {
        if accessibility.prefersIncreasedContrast {
            return adjustContrast(baseTheme.contentTertiary, by: 0.2)
        }
        return baseTheme.contentTertiary
    }
    
    public var contentDisabled: Color {
        baseTheme.contentDisabled
    }
    
    // MARK: - Border Colors
    
    public var borderPrimary: Color {
        if accessibility.prefersIncreasedContrast {
            return adjustContrast(baseTheme.borderPrimary, by: 0.2)
        }
        return baseTheme.borderPrimary
    }
    
    public var borderSecondary: Color {
        baseTheme.borderSecondary
    }
    
    public var borderFocused: Color {
        baseTheme.borderFocused
    }
    
    // MARK: - Interactive Colors
    
    public var interactiveNormal: Color {
        baseTheme.interactiveNormal
    }
    
    public var interactiveHover: Color {
        baseTheme.interactiveHover
    }
    
    public var interactiveActive: Color {
        baseTheme.interactiveActive
    }
    
    public var interactiveDisabled: Color {
        baseTheme.interactiveDisabled
    }
    
    // MARK: - Accent Colors
    
    public var accentPrimary: Color {
        baseTheme.accentPrimary
    }
    
    public var accentSecondary: Color {
        baseTheme.accentSecondary
    }
    
    // MARK: - Semantic Colors
    
    public var semanticSuccess: Color {
        baseTheme.semanticSuccess
    }
    
    public var semanticWarning: Color {
        baseTheme.semanticWarning
    }
    
    public var semanticError: Color {
        baseTheme.semanticError
    }
    
    public var semanticInfo: Color {
        baseTheme.semanticInfo
    }
    
    // MARK: - Spacing
    
    public var spacingInset: CGFloat {
        baseTheme.spacingInset
    }
    
    public var spacingStack: CGFloat {
        baseTheme.spacingStack
    }
    
    public var spacingSection: CGFloat {
        baseTheme.spacingSection
    }
    
    public var spacingInline: CGFloat {
        baseTheme.spacingInline
    }
    
    // MARK: - Radius
    
    public var radiusSmall: CGFloat {
        baseTheme.radiusSmall
    }
    
    public var radiusMedium: CGFloat {
        baseTheme.radiusMedium
    }
    
    public var radiusLarge: CGFloat {
        baseTheme.radiusLarge
    }
    
    public var radiusFull: CGFloat {
        baseTheme.radiusFull
    }
    
    // MARK: - Shadows
    
    public var shadowSmall: WeekoFoundationTokens.ShadowPrimitive {
        if accessibility.prefersReducedTransparency {
            // Reduce shadow opacity
            let base = baseTheme.shadowSmall
            return WeekoFoundationTokens.ShadowPrimitive(
                radius: base.radius,
                x: base.x,
                y: base.y,
                opacity: base.opacity * 0.5
            )
        }
        return baseTheme.shadowSmall
    }
    
    public var shadowMedium: WeekoFoundationTokens.ShadowPrimitive {
        if accessibility.prefersReducedTransparency {
            let base = baseTheme.shadowMedium
            return WeekoFoundationTokens.ShadowPrimitive(
                radius: base.radius,
                x: base.x,
                y: base.y,
                opacity: base.opacity * 0.5
            )
        }
        return baseTheme.shadowMedium
    }
    
    public var shadowLarge: WeekoFoundationTokens.ShadowPrimitive {
        if accessibility.prefersReducedTransparency {
            let base = baseTheme.shadowLarge
            return WeekoFoundationTokens.ShadowPrimitive(
                radius: base.radius,
                x: base.x,
                y: base.y,
                opacity: base.opacity * 0.5
            )
        }
        return baseTheme.shadowLarge
    }
    
    // MARK: - Animation
    
    public var animationFast: Double {
        accessibility.prefersReducedMotion ? 0 : baseTheme.animationFast
    }
    
    public var animationNormal: Double {
        accessibility.prefersReducedMotion ? 0 : baseTheme.animationNormal
    }
    
    public var animationSlow: Double {
        accessibility.prefersReducedMotion ? 0 : baseTheme.animationSlow
    }
    
    public var prefersReducedMotion: Bool {
        accessibility.prefersReducedMotion
    }
    
    // MARK: - Helpers
    
    private func adjustContrast(_ color: Color, by amount: Double) -> Color {
        // Simple brightness adjustment for increased contrast
        // In a real implementation, you might want to use more sophisticated color math
        return color.opacity(1.0 + amount)
    }
}
