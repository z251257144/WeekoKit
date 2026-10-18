//
//  WeekoDefaultLightTheme.swift
//  WeekoKit
//
//  Default light theme implementation
//

import SwiftUI

/// Default light theme for WeekoKit components
public struct WeekoDefaultLightTheme: WeekoTheme {
    
    public init() {}
    
    // MARK: - Surface Colors
    
    public var surfaceBackground: Color {
        .white
    }
    
    public var surfaceRaised: Color {
        WeekoFoundationTokens.ColorPrimitive.slate100
    }
    
    public var surfaceOverlay: Color {
        WeekoFoundationTokens.ColorPrimitive.slate50
    }
    
    public var surfaceElevated: Color {
        .white
    }
    
    // MARK: - Content Colors
    
    public var contentPrimary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate900
    }
    
    public var contentSecondary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate600
    }
    
    public var contentTertiary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate500
    }
    
    public var contentDisabled: Color {
        WeekoFoundationTokens.ColorPrimitive.slate400
    }
    
    // MARK: - Border Colors
    
    public var borderPrimary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate300
    }
    
    public var borderSecondary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate200
    }
    
    public var borderFocused: Color {
        WeekoFoundationTokens.ColorPrimitive.blue600
    }
    
    // MARK: - Interactive Colors
    
    public var interactiveNormal: Color {
        Color.black.opacity(0.03)
    }
    
    public var interactiveHover: Color {
        Color.black.opacity(0.06)
    }
    
    public var interactiveActive: Color {
        Color.black.opacity(0.10)
    }
    
    public var interactiveDisabled: Color {
        Color.black.opacity(0.01)
    }
    
    // MARK: - Accent Colors
    
    public var accentPrimary: Color {
        WeekoFoundationTokens.ColorPrimitive.blue600
    }
    
    public var accentSecondary: Color {
        WeekoFoundationTokens.ColorPrimitive.blue500
    }
    
    // MARK: - Semantic Colors
    
    public var semanticSuccess: Color {
        WeekoFoundationTokens.ColorPrimitive.green600
    }
    
    public var semanticWarning: Color {
        WeekoFoundationTokens.ColorPrimitive.orange600
    }
    
    public var semanticError: Color {
        WeekoFoundationTokens.ColorPrimitive.red
    }
    
    public var semanticInfo: Color {
        WeekoFoundationTokens.ColorPrimitive.blue600
    }
    
    // MARK: - Spacing
    
    public var spacingInset: CGFloat {
        WeekoFoundationTokens.SpacingPrimitive.space3
    }
    
    public var spacingStack: CGFloat {
        WeekoFoundationTokens.SpacingPrimitive.space2
    }
    
    public var spacingSection: CGFloat {
        WeekoFoundationTokens.SpacingPrimitive.space4
    }
    
    public var spacingInline: CGFloat {
        WeekoFoundationTokens.SpacingPrimitive.space2
    }
    
    // MARK: - Radius
    
    public var radiusSmall: CGFloat {
        WeekoFoundationTokens.RadiusPrimitive.radius2
    }
    
    public var radiusMedium: CGFloat {
        WeekoFoundationTokens.RadiusPrimitive.radius4
    }
    
    public var radiusLarge: CGFloat {
        WeekoFoundationTokens.RadiusPrimitive.radius6
    }
    
    public var radiusFull: CGFloat {
        WeekoFoundationTokens.RadiusPrimitive.radiusFull
    }
    
    // MARK: - Shadows
    
    public var shadowSmall: WeekoFoundationTokens.ShadowPrimitive {
        .small
    }
    
    public var shadowMedium: WeekoFoundationTokens.ShadowPrimitive {
        .medium
    }
    
    public var shadowLarge: WeekoFoundationTokens.ShadowPrimitive {
        .large
    }
}
