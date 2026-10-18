//
//  DemoThemePage.swift
//  WeekoKitDemo
//
//  Demonstration of WeekoKit theme system
//

import SwiftUI
import WeekoKit

struct DemoThemePage: View {
    @StateObject private var accessibility = WeekoAccessibilityObserver()
    @State private var selectedTheme: ThemeOption = .darkDefault
    @State private var enhancement: WeekoVisualEnhancement = .standard
    @State private var useAdaptive = false
    
    enum ThemeOption: String, CaseIterable, Identifiable {
        case darkDefault = "Dark (Default)"
        case lightDefault = "Light (Default)"
        case custom = "Custom Brand"
        
        var id: String { rawValue }
        
        func theme() -> WeekoTheme {
            switch self {
            case .darkDefault:
                return WeekoDefaultDarkTheme()
            case .lightDefault:
                return WeekoDefaultLightTheme()
            case .custom:
                return CustomBrandTheme()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                themeControls
                componentShowcase
            }
            .padding()
        }
        .weekoTheme(currentTheme)
        .weekoVisualEnhancement(enhancement)
    }
    
    private var currentTheme: WeekoTheme {
        if useAdaptive {
            return WeekoAdaptiveTheme(
                baseTheme: selectedTheme.theme(),
                accessibility: accessibility
            )
        } else {
            return selectedTheme.theme()
        }
    }
    
    private var themeControls: some View {
        VStack(spacing: 16) {
            Text("Theme System Demo")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            GroupBox("Theme Selection") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Base Theme", selection: $selectedTheme) {
                        ForEach(ThemeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Use Adaptive Theme (Accessibility)", isOn: $useAdaptive)
                    
                    if useAdaptive {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Reduced Motion: \(accessibility.prefersReducedMotion ? "On" : "Off")", systemImage: "figure.walk.motion")
                            Label("Reduced Transparency: \(accessibility.prefersReducedTransparency ? "On" : "Off")", systemImage: "eye.slash")
                            Label("Increased Contrast: \(accessibility.prefersIncreasedContrast ? "On" : "Off")", systemImage: "circle.lefthalf.filled")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            
            GroupBox("Visual Enhancement") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Level", selection: $enhancement) {
                        Text("Minimal").tag(WeekoVisualEnhancement.minimal)
                        Text("Standard").tag(WeekoVisualEnhancement.standard)
                        Text("Enhanced").tag(WeekoVisualEnhancement.enhanced)
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        enhancementBadge("Hover", enabled: enhancement.contains(.hover))
                        enhancementBadge("Icon Wells", enabled: enhancement.contains(.iconWells))
                        enhancementBadge("Animations", enabled: enhancement.contains(.animations))
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
    }
    
    private func enhancementBadge(_ label: String, enabled: Bool) -> some View {
        HStack {
            Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(enabled ? .green : .secondary)
            Text(label)
                .font(.caption)
        }
    }
    
    @ViewBuilder
    private var componentShowcase: some View {
        VStack(spacing: 16) {
            Text("Component Showcase")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            colorShowcase
            buttonShowcase
            cardShowcase
        }
    }
    
    @ViewBuilder
    private var colorShowcase: some View {
        GroupBox("Colors") {
            VStack(spacing: 12) {
                ColorRow(label: "Surface Background", color: currentTheme.surfaceBackground)
                ColorRow(label: "Surface Raised", color: currentTheme.surfaceRaised)
                ColorRow(label: "Surface Overlay", color: currentTheme.surfaceOverlay)
                Divider()
                ColorRow(label: "Content Primary", color: currentTheme.contentPrimary)
                ColorRow(label: "Content Secondary", color: currentTheme.contentSecondary)
                ColorRow(label: "Content Tertiary", color: currentTheme.contentTertiary)
                Divider()
                ColorRow(label: "Accent Primary", color: currentTheme.accentPrimary)
                ColorRow(label: "Semantic Success", color: currentTheme.semanticSuccess)
                ColorRow(label: "Semantic Warning", color: currentTheme.semanticWarning)
                ColorRow(label: "Semantic Error", color: currentTheme.semanticError)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var buttonShowcase: some View {
        GroupBox("Interactive Elements") {
            VStack(spacing: 12) {
                HStack {
                    InteractiveBox(state: "Normal", color: currentTheme.interactiveNormal)
                    InteractiveBox(state: "Hover", color: currentTheme.interactiveHover)
                    InteractiveBox(state: "Active", color: currentTheme.interactiveActive)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var cardShowcase: some View {
        GroupBox("Sample Card") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Featured Item")
                        .font(.headline)
                        .foregroundColor(currentTheme.contentPrimary)
                }
                
                Text("This is a sample card demonstrating the current theme's appearance with text content and spacing.")
                    .font(.body)
                    .foregroundColor(currentTheme.contentSecondary)
                
                Text("Last updated: Today")
                    .font(.caption)
                    .foregroundColor(currentTheme.contentTertiary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(currentTheme.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: currentTheme.radiusMedium))
            .weekoBorder(currentTheme.borderSecondary, radius: currentTheme.radiusMedium)
            .weekoShadow(currentTheme.shadowMedium)
        }
    }
}

struct ColorRow: View {
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 60, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.primary.opacity(0.2), lineWidth: 0.5)
                )
        }
    }
}

struct InteractiveBox: View {
    let state: String
    let color: Color
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
            
            Text(state)
                .font(.caption)
        }
    }
}

// Custom brand theme example
struct CustomBrandTheme: WeekoTheme {
    var surfaceBackground = Color(red: 0.10, green: 0.10, blue: 0.18)  // #1a1a2e
    var surfaceRaised = Color(red: 0.09, green: 0.13, blue: 0.24)      // #16213e
    var surfaceOverlay = Color(red: 0.06, green: 0.20, blue: 0.38)     // #0f3460
    var surfaceElevated = Color(red: 0.06, green: 0.20, blue: 0.38)
    
    var contentPrimary = Color.white
    var contentSecondary = Color.white.opacity(0.7)
    var contentTertiary = Color.white.opacity(0.5)
    var contentDisabled = Color.white.opacity(0.3)
    
    var borderPrimary = Color.white.opacity(0.15)
    var borderSecondary = Color.white.opacity(0.08)
    var borderFocused = Color(red: 0.91, green: 0.27, blue: 0.38)      // #e94560
    
    var interactiveNormal = Color.white.opacity(0.05)
    var interactiveHover = Color.white.opacity(0.10)
    var interactiveActive = Color.white.opacity(0.15)
    var interactiveDisabled = Color.white.opacity(0.02)
    
    var accentPrimary = Color(red: 0.91, green: 0.27, blue: 0.38)      // #e94560
    var accentSecondary = Color(red: 1.00, green: 0.42, blue: 0.62)    // #ff6b9d
    
    var semanticSuccess = Color(red: 0.18, green: 0.80, blue: 0.44)    // #2ecc71
    var semanticWarning = Color(red: 0.95, green: 0.61, blue: 0.07)    // #f39c12
    var semanticError = Color(red: 0.91, green: 0.30, blue: 0.24)      // #e74c3c
    var semanticInfo = Color(red: 0.20, green: 0.60, blue: 0.86)       // #3498db
    
    var spacingInset: CGFloat = 12
    var spacingStack: CGFloat = 8
    var spacingSection: CGFloat = 16
    var spacingInline: CGFloat = 8
    
    var radiusSmall: CGFloat = 6
    var radiusMedium: CGFloat = 10
    var radiusLarge: CGFloat = 14
    var radiusFull: CGFloat = 999
    
    var shadowSmall = WeekoFoundationTokens.ShadowPrimitive.small
    var shadowMedium = WeekoFoundationTokens.ShadowPrimitive.medium
    var shadowLarge = WeekoFoundationTokens.ShadowPrimitive.large
}

#Preview {
    DemoThemePage()
        .frame(width: 800, height: 1000)
}
