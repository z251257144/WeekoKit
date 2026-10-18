//
//  WeekoViewExtensions.swift
//  WeekoKit
//
//  View extensions for theme-aware styling
//

import SwiftUI

// MARK: - Conditional Modifier

public extension View {
    /// Apply a modifier conditionally
    /// - Parameters:
    ///   - condition: Whether to apply the modifier
    ///   - transform: The modifier to apply
    @ViewBuilder
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Theme-Aware Shadow

public extension View {
    /// Apply a theme-aware shadow
    /// - Parameters:
    ///   - shadow: The shadow primitive from theme
    ///   - color: Optional color override (defaults to black)
    func weekoShadow(
        _ shadow: WeekoFoundationTokens.ShadowPrimitive,
        color: Color = .black
    ) -> some View {
        self.shadow(
            color: color.opacity(shadow.opacity),
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Theme-Aware Border

public extension View {
    /// Apply a theme-aware border with corner radius
    /// - Parameters:
    ///   - color: Border color
    ///   - width: Border width
    ///   - radius: Corner radius
    func weekoBorder(
        _ color: Color,
        width: CGFloat = 1,
        radius: CGFloat
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(color, lineWidth: width)
        )
    }
}

// MARK: - Animated Value

public extension View {
    /// Apply animation to a value, respecting reduced motion preferences
    /// - Parameters:
    ///   - duration: Animation duration
    ///   - value: The value to animate
    ///   - prefersReducedMotion: Whether to skip animation
    func weekoAnimation<V: Equatable>(
        duration: Double,
        value: V,
        prefersReducedMotion: Bool = false
    ) -> some View {
        self.animation(
            prefersReducedMotion ? nil : .easeOut(duration: duration),
            value: value
        )
    }
}
