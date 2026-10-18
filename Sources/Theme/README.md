# WeekoKit Theme System

A comprehensive theming system for WeekoKit components that supports customization, accessibility, and visual enhancement levels.

## Overview

The WeekoKit theme system provides:

- **Semantic design tokens** - Color, spacing, and style values organized by purpose
- **Multiple themes** - Built-in light and dark themes, plus full customization
- **Accessibility support** - Automatic adaptation to system preferences
- **Visual enhancement levels** - Control performance vs. visual richness
- **SwiftUI integration** - Environment-based theming with clean modifiers

## Quick Start

### Basic Usage

Apply the default dark theme to your app:

```swift
import SwiftUI
import WeekoKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .weekoTheme(WeekoDefaultDarkTheme())
        }
    }
}
```

### Use Light Theme

```swift
ContentView()
    .weekoTheme(WeekoDefaultLightTheme())
```

### Configure Visual Enhancement

```swift
// Minimal - best performance, clean appearance
ContentView()
    .weekoTheme(WeekoDefaultDarkTheme())
    .weekoVisualEnhancement(.minimal)

// Standard - balanced (default)
ContentView()
    .weekoTheme(WeekoDefaultDarkTheme())
    .weekoVisualEnhancement(.standard)

// Enhanced - maximum visual richness
ContentView()
    .weekoTheme(WeekoDefaultDarkTheme())
    .weekoVisualEnhancement(.enhanced)
```

## Creating Custom Themes

### Simple Custom Theme

```swift
import WeekoKit

struct MyBrandTheme: WeekoTheme {
    // Surface colors
    var surfaceBackground = Color(hex: "#1a1a2e")
    var surfaceRaised = Color(hex: "#16213e")
    var surfaceOverlay = Color(hex: "#0f3460")
    var surfaceElevated = Color(hex: "#0f3460")
    
    // Content colors
    var contentPrimary = Color.white
    var contentSecondary = Color.white.opacity(0.7)
    var contentTertiary = Color.white.opacity(0.5)
    var contentDisabled = Color.white.opacity(0.3)
    
    // Border colors
    var borderPrimary = Color.white.opacity(0.15)
    var borderSecondary = Color.white.opacity(0.08)
    var borderFocused = Color(hex: "#e94560")
    
    // Interactive colors
    var interactiveNormal = Color.white.opacity(0.05)
    var interactiveHover = Color.white.opacity(0.10)
    var interactiveActive = Color.white.opacity(0.15)
    var interactiveDisabled = Color.white.opacity(0.02)
    
    // Accent colors
    var accentPrimary = Color(hex: "#e94560")
    var accentSecondary = Color(hex: "#ff6b9d")
    
    // Semantic colors
    var semanticSuccess = Color(hex: "#2ecc71")
    var semanticWarning = Color(hex: "#f39c12")
    var semanticError = Color(hex: "#e74c3c")
    var semanticInfo = Color(hex: "#3498db")
    
    // Spacing (use defaults or customize)
    var spacingInset: CGFloat = 12
    var spacingStack: CGFloat = 8
    var spacingSection: CGFloat = 16
    var spacingInline: CGFloat = 8
    
    // Radius
    var radiusSmall: CGFloat = 6
    var radiusMedium: CGFloat = 10
    var radiusLarge: CGFloat = 14
    var radiusFull: CGFloat = 999
    
    // Shadows
    var shadowSmall = WeekoFoundationTokens.ShadowPrimitive.small
    var shadowMedium = WeekoFoundationTokens.ShadowPrimitive.medium
    var shadowLarge = WeekoFoundationTokens.ShadowPrimitive.large
}

// Use it
MyApp()
    .weekoTheme(MyBrandTheme())
```

### Adaptive Theme (Responds to Accessibility)

```swift
import WeekoKit

@main
struct MyApp: App {
    @StateObject private var accessibility = WeekoAccessibilityObserver()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .weekoTheme(
                    WeekoAdaptiveTheme(
                        baseTheme: WeekoDefaultDarkTheme(),
                        accessibility: accessibility
                    )
                )
        }
    }
}
```

The adaptive theme automatically:
- Increases contrast when user enables "Increase Contrast"
- Reduces shadow opacity when user enables "Reduce Transparency"
- Disables animations when user enables "Reduce Motion"

## Visual Enhancement Options

```swift
public struct WeekoVisualEnhancement: OptionSet {
    public static let shadows      // Shadows on cards and elevated elements
    public static let borders      // Subtle borders on components
    public static let hover        // Hover states for interactive elements
    public static let iconWells    // Decorative icon backgrounds
    public static let animations   // Subtle transitions
    public static let blur         // Background blur effects
    
    // Presets
    public static let minimal      // No enhancements (best performance)
    public static let standard     // borders + hover (balanced)
    public static let enhanced     // All except blur (rich visuals)
    public static let maximum      // All enhancements
}
```

### Custom Enhancement Combination

```swift
ContentView()
    .weekoVisualEnhancement([.borders, .hover, .animations])
```

## Accessing Theme in Custom Components

```swift
import SwiftUI
import WeekoKit

struct MyCustomComponent: View {
    @Environment(\.weekoTheme) private var theme
    @Environment(\.weekoVisualEnhancement) private var enhancement
    
    var body: some View {
        VStack(spacing: theme.spacingStack) {
            Text("Custom Component")
                .foregroundColor(theme.contentPrimary)
            
            Text("Subtitle")
                .foregroundColor(theme.contentSecondary)
        }
        .padding(theme.spacingInset)
        .background(theme.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: theme.radiusMedium))
        .conditionalModifier(enhancement.contains(.shadows)) { view in
            view.weekoShadow(theme.shadowSmall)
        }
    }
}
```

## Theme-Aware View Extensions

### Apply Shadow

```swift
myView
    .weekoShadow(theme.shadowMedium)
```

### Apply Border

```swift
myView
    .weekoBorder(theme.borderPrimary, width: 1, radius: theme.radiusMedium)
```

### Conditional Animation

```swift
myView
    .weekoAnimation(
        duration: theme.animationNormal,
        value: someState,
        prefersReducedMotion: theme.prefersReducedMotion
    )
```

### Conditional Modifier

```swift
myView
    .conditionalModifier(enhancement.contains(.hover)) { view in
        view.onHover { hovering in
            // Handle hover
        }
    }
```

## Foundation Tokens

Low-level primitive values are available for advanced customization:

```swift
// Colors
WeekoFoundationTokens.ColorPrimitive.slate900
WeekoFoundationTokens.ColorPrimitive.blue500
WeekoFoundationTokens.ColorPrimitive.green600

// Spacing
WeekoFoundationTokens.SpacingPrimitive.space4  // 16pt
WeekoFoundationTokens.SpacingPrimitive.space8  // 32pt

// Radius
WeekoFoundationTokens.RadiusPrimitive.radius4  // 10pt
WeekoFoundationTokens.RadiusPrimitive.radiusFull  // 999pt (pill)

// Shadows
WeekoFoundationTokens.ShadowPrimitive.small
WeekoFoundationTokens.ShadowPrimitive.medium
```

## Best Practices

### 1. Theme at App Level

Apply theme once at the app root, not on every component:

```swift
// ✅ Good
WindowGroup {
    ContentView()
        .weekoTheme(myTheme)
}

// ❌ Avoid
struct ContentView: View {
    var body: some View {
        VStack {
            ComponentA().weekoTheme(myTheme)
            ComponentB().weekoTheme(myTheme)
        }
    }
}
```

### 2. Use Semantic Tokens

Prefer semantic theme properties over foundation primitives:

```swift
// ✅ Good - adapts with theme
Text("Hello")
    .foregroundColor(theme.contentPrimary)

// ❌ Avoid - hardcoded
Text("Hello")
    .foregroundColor(.white)
```

### 3. Respect Accessibility Preferences

Use the adaptive theme or check preferences manually:

```swift
// Option 1: Use adaptive theme
.weekoTheme(WeekoAdaptiveTheme(baseTheme: myTheme, accessibility: observer))

// Option 2: Check manually
if theme.prefersReducedMotion {
    // Skip animation
} else {
    // Animate
}
```

### 4. Performance Considerations

For long lists or performance-critical views:

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
.weekoVisualEnhancement(.minimal)  // Disable heavy effects in lists
```

### 5. Testing Different Themes

Provide theme switching for testing:

```swift
struct ContentView: View {
    @State private var useLightTheme = false
    
    var body: some View {
        mainContent
            .weekoTheme(useLightTheme ? WeekoDefaultLightTheme() : WeekoDefaultDarkTheme())
        
        Toggle("Light Theme", isOn: $useLightTheme)
    }
}
```

## Migration Guide

### Migrating Existing Components

Before:
```swift
Text("Title")
    .foregroundStyle(.primary)
    .padding(12)
```

After:
```swift
@Environment(\.weekoTheme) private var theme

Text("Title")
    .foregroundStyle(theme.contentPrimary)
    .padding(theme.spacingInset)
```

## Architecture

```
Foundation Tokens (Primitives)
    ↓
WeekoTheme Protocol (Semantic)
    ↓
Concrete Themes (Dark, Light, Custom)
    ↓
Environment Values
    ↓
Components
```

This layered approach ensures:
- **Flexibility** - Easy to create custom themes
- **Consistency** - Semantic tokens keep designs coherent
- **Maintainability** - Change primitives without touching components
- **Performance** - Environment-based, no prop drilling

## Examples

See the Demo app for complete examples of:
- Theme switching
- Custom brand themes
- Accessibility adaptation
- Visual enhancement levels
- Custom themed components
