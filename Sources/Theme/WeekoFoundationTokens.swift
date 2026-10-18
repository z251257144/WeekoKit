//
//  WeekoFoundationTokens.swift
//  WeekoKit
//
//  Foundation design tokens - primitive values
//

import SwiftUI

/// Foundation design tokens providing primitive values for colors, spacing, and other design properties.
/// These are the lowest level tokens that should be mapped to semantic tokens through WeekoTheme.
public enum WeekoFoundationTokens {
    
    // MARK: - Color Primitives
    
    /// Primitive color values organized by hue and lightness
    public enum ColorPrimitive {
        // Slate scale (cool neutral)
        public static let slate950 = Color(red: 0.02, green: 0.03, blue: 0.07)  // #05070C
        public static let slate900 = Color(red: 0.04, green: 0.05, blue: 0.11)  // #0A0D12
        public static let slate850 = Color(red: 0.06, green: 0.07, blue: 0.11)  // #0F131C
        public static let slate800 = Color(red: 0.09, green: 0.11, blue: 0.17)  // #161D2B
        public static let slate750 = Color(red: 0.12, green: 0.15, blue: 0.21)  // #1E2636
        public static let slate700 = Color(red: 0.18, green: 0.21, blue: 0.28)  // #2E3544
        public static let slate600 = Color(red: 0.29, green: 0.33, blue: 0.40)  // #4A5466
        public static let slate500 = Color(red: 0.45, green: 0.49, blue: 0.56)  // #737D8F
        public static let slate400 = Color(red: 0.64, green: 0.67, blue: 0.72)  // #A3ABB8
        public static let slate300 = Color(red: 0.80, green: 0.82, blue: 0.85)  // #CCD1D9
        public static let slate200 = Color(red: 0.91, green: 0.92, blue: 0.94)  // #E8EAF0
        public static let slate100 = Color(red: 0.97, green: 0.97, blue: 0.98)  // #F7F8FA
        public static let slate50 = Color(red: 0.99, green: 0.99, blue: 1.00)   // #FCFCFF
        
        // Blue accent
        public static let blue600 = Color(red: 0.22, green: 0.43, blue: 1.00)   // #3B6DFF
        public static let blue500 = Color(red: 0.22, green: 0.74, blue: 0.97)   // #38BDF8
        public static let blue400 = Color(red: 0.49, green: 0.82, blue: 1.00)   // #7DD3FF
        
        // Green accent
        public static let green600 = Color(red: 0.16, green: 0.73, blue: 0.58)  // #29BAA4
        public static let green500 = Color(red: 0.43, green: 0.91, blue: 0.72)  // #6EE7B7
        public static let green400 = Color(red: 0.64, green: 0.95, blue: 0.83)  // #A3F3D4
        
        // Orange/Amber accent
        public static let orange600 = Color(red: 0.91, green: 0.49, blue: 0.20) // #E87D33
        public static let orange500 = Color(red: 0.91, green: 0.65, blue: 0.41) // #E9A568
        public static let orange400 = Color(red: 0.95, green: 0.77, blue: 0.60) // #F2C499
        
        // System colors
        public static let red = Color(red: 1.00, green: 0.27, blue: 0.23)       // #FF4538
        public static let yellow = Color(red: 1.00, green: 0.80, blue: 0.00)    // #FFCC00
        public static let purple = Color(red: 0.69, green: 0.51, blue: 1.00)    // #B082FF
    }
    
    // MARK: - Spacing Primitives
    
    /// Spacing scale based on 4pt grid system
    public enum SpacingPrimitive {
        public static let space0: CGFloat = 0
        public static let space1: CGFloat = 4
        public static let space2: CGFloat = 8
        public static let space3: CGFloat = 12
        public static let space4: CGFloat = 16
        public static let space5: CGFloat = 20
        public static let space6: CGFloat = 24
        public static let space7: CGFloat = 28
        public static let space8: CGFloat = 32
        public static let space10: CGFloat = 40
        public static let space12: CGFloat = 48
        public static let space16: CGFloat = 64
    }
    
    // MARK: - Radius Primitives
    
    /// Border radius scale
    public enum RadiusPrimitive {
        public static let radius0: CGFloat = 0
        public static let radius1: CGFloat = 4
        public static let radius2: CGFloat = 6
        public static let radius3: CGFloat = 8
        public static let radius4: CGFloat = 10
        public static let radius5: CGFloat = 12
        public static let radius6: CGFloat = 14
        public static let radius8: CGFloat = 16
        public static let radiusFull: CGFloat = 999
    }
    
    // MARK: - Shadow Primitives
    
    /// Shadow definitions
    public struct ShadowPrimitive {
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
        public let opacity: Double
        
        public init(radius: CGFloat, x: CGFloat = 0, y: CGFloat, opacity: Double) {
            self.radius = radius
            self.x = x
            self.y = y
            self.opacity = opacity
        }
        
        public static let none = ShadowPrimitive(radius: 0, y: 0, opacity: 0)
        public static let subtle = ShadowPrimitive(radius: 2, y: 1, opacity: 0.08)
        public static let small = ShadowPrimitive(radius: 4, y: 2, opacity: 0.10)
        public static let medium = ShadowPrimitive(radius: 8, y: 4, opacity: 0.12)
        public static let large = ShadowPrimitive(radius: 16, y: 8, opacity: 0.15)
        public static let xlarge = ShadowPrimitive(radius: 24, y: 12, opacity: 0.18)
    }
}
