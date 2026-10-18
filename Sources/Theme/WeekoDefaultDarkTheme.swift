//
//  WeekoDefaultDarkTheme.swift
//  WeekoKit
//
//  Default dark theme implementation
//

import SwiftUI

/// Default dark theme for WeekoKit components
public struct WeekoDefaultDarkTheme: WeekoTheme {
    
    public init() {}
    
    // MARK: - Surface Colors
    
    public var surfaceBackground: Color {
        WeekoFoundationTokens.ColorPrimitive.slate950
    }
    
    public var surfaceRaised: Color {
        WeekoFoundationTokens.ColorPrimitive.slate900
    }
    
    public var surfaceOverlay: Color {
        WeekoFoundationTokens.ColorPrimitive.slate850
    }
    
    public var surfaceElevated: Color {
        WeekoFoundationTokens.ColorPrimitive.slate800
    }
    
    // MARK: - Content Colors
    
    public var contentPrimary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate50
    }
    
    public var contentSecondary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate300
    }
    
    public var contentTertiary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate500
    }
    
    public var contentDisabled: Color {
        WeekoFoundationTokens.ColorPrimitive.slate600
    }
    
    // MARK: - Border Colors
    
    public var borderPrimary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate700
    }
    
    public var borderSecondary: Color {
        WeekoFoundationTokens.ColorPrimitive.slate800
    }
    
    public var borderFocused: Color {
        WeekoFoundationTokens.ColorPrimitive.blue500
    }
    
    // MARK: - Interactive Colors
    
    public var interactiveNormal: Color {
        Color.white.opacity(0.05)
    }
    
    public var interactiveHover: Color {
        Color.white.opacity(0.08)
    }
    
    public var interactiveActive: Color {
        Color.white.opacity(0.12)
    }
    
    public var interactiveDisabled: Color {
        Color.white.opacity(0.02)
    }
    
    // MARK: - Accent Colors
    
    public var accentPrimary: Color {
        WeekoFoundationTokens.ColorPrimitive.blue500
    }
    
    public var accentSecondary: Color {
        WeekoFoundationTokens.ColorPrimitive.blue400
    }
    
    // MARK: - Semantic Colors
    
    public var semanticSuccess: Color {
        WeekoFoundationTokens.ColorPrimitive.green500
    }
    
    public var semanticWarning: Color {
        WeekoFoundationTokens.ColorPrimitive.orange500
    }
    
    public var semanticError: Color {
        WeekoFoundationTokens.ColorPrimitive.red
    }
    
    public var semanticInfo: Color {
        WeekoFoundationTokens.ColorPrimitive.blue500
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
