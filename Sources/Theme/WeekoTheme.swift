//
//  WeekoTheme.swift
//  WeekoKit
//
//  Theme protocol defining semantic design tokens
//

import SwiftUI

/// Protocol defining semantic design tokens that can be customized per theme.
/// Implement this protocol to create custom themes for WeekoKit components.
public protocol WeekoTheme {
    
    // MARK: - Surface Colors
    
    /// Background color for the main surface (window background)
    var surfaceBackground: Color { get }
    
    /// Background color for raised surfaces (cards, panels)
    var surfaceRaised: Color { get }
    
    /// Background color for overlay surfaces (popovers, modals)
    var surfaceOverlay: Color { get }
    
    /// Background color for elevated surfaces (tooltips, floating elements)
    var surfaceElevated: Color { get }
    
    // MARK: - Content Colors
    
    /// Primary text and icon color (high emphasis)
    var contentPrimary: Color { get }
    
    /// Secondary text and icon color (medium emphasis)
    var contentSecondary: Color { get }
    
    /// Tertiary text and icon color (low emphasis)
    var contentTertiary: Color { get }
    
    /// Disabled text and icon color
    var contentDisabled: Color { get }
    
    // MARK: - Border Colors
    
    /// Primary border color
    var borderPrimary: Color { get }
    
    /// Secondary border color (subtle)
    var borderSecondary: Color { get }
    
    /// Focused border color
    var borderFocused: Color { get }
    
    // MARK: - Interactive Colors
    
    /// Normal state for interactive elements
    var interactiveNormal: Color { get }
    
    /// Hover state for interactive elements
    var interactiveHover: Color { get }
    
    /// Active/pressed state for interactive elements
    var interactiveActive: Color { get }
    
    /// Disabled state for interactive elements
    var interactiveDisabled: Color { get }
    
    // MARK: - Accent Colors
    
    /// Primary accent color (brand color)
    var accentPrimary: Color { get }
    
    /// Secondary accent color
    var accentSecondary: Color { get }
    
    // MARK: - Semantic Colors
    
    /// Success state color
    var semanticSuccess: Color { get }
    
    /// Warning state color
    var semanticWarning: Color { get }
    
    /// Error state color
    var semanticError: Color { get }
    
    /// Info state color
    var semanticInfo: Color { get }
    
    // MARK: - Spacing
    
    /// Inset spacing (padding inside components)
    var spacingInset: CGFloat { get }
    
    /// Stack spacing (space between items in a stack)
    var spacingStack: CGFloat { get }
    
    /// Section spacing (space between sections)
    var spacingSection: CGFloat { get }
    
    /// Inline spacing (space between inline elements)
    var spacingInline: CGFloat { get }
    
    // MARK: - Radius
    
    /// Small corner radius (buttons, chips)
    var radiusSmall: CGFloat { get }
    
    /// Medium corner radius (cards, inputs)
    var radiusMedium: CGFloat { get }
    
    /// Large corner radius (panels, modals)
    var radiusLarge: CGFloat { get }
    
    /// Full corner radius (pills, circles)
    var radiusFull: CGFloat { get }
    
    // MARK: - Shadows
    
    /// Shadow for small elevated elements
    var shadowSmall: WeekoFoundationTokens.ShadowPrimitive { get }
    
    /// Shadow for medium elevated elements
    var shadowMedium: WeekoFoundationTokens.ShadowPrimitive { get }
    
    /// Shadow for large elevated elements
    var shadowLarge: WeekoFoundationTokens.ShadowPrimitive { get }
    
    // MARK: - Typography
    
    /// Line height for body text
    var lineHeightBody: CGFloat { get }
    
    /// Line height for headings
    var lineHeightHeading: CGFloat { get }
    
    /// Letter spacing for display text
    var letterSpacingDisplay: CGFloat { get }
    
    // MARK: - Animation
    
    /// Duration for fast animations
    var animationFast: Double { get }
    
    /// Duration for normal animations
    var animationNormal: Double { get }
    
    /// Duration for slow animations
    var animationSlow: Double { get }
    
    /// Whether to reduce motion (respects system preferences)
    var prefersReducedMotion: Bool { get }
}

// MARK: - Default Values

public extension WeekoTheme {
    // Provide sensible defaults
    var lineHeightBody: CGFloat { 1.5 }
    var lineHeightHeading: CGFloat { 1.2 }
    var letterSpacingDisplay: CGFloat { -0.02 }
    
    var animationFast: Double { 0.15 }
    var animationNormal: Double { 0.25 }
    var animationSlow: Double { 0.35 }
    
    var prefersReducedMotion: Bool {
        #if os(macOS)
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #else
        false
        #endif
    }
}
