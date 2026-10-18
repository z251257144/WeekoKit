//
//  WeekoAccessibilityObserver.swift
//  WeekoKit
//
//  Accessibility preferences observer
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Observes system accessibility preferences and publishes changes
@available(macOS 10.15, *)
public final class WeekoAccessibilityObserver: ObservableObject {
    
    /// Whether the system prefers reduced motion
    @Published public private(set) var prefersReducedMotion: Bool
    
    /// Whether the system prefers reduced transparency
    @Published public private(set) var prefersReducedTransparency: Bool
    
    /// Whether the system prefers increased contrast
    @Published public private(set) var prefersIncreasedContrast: Bool
    
    public init() {
        #if os(macOS)
        self.prefersReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        self.prefersReducedTransparency = NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        self.prefersIncreasedContrast = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
        
        // Observe accessibility preference changes
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        #else
        self.prefersReducedMotion = false
        self.prefersReducedTransparency = false
        self.prefersIncreasedContrast = false
        #endif
    }
    
    private func updateAccessibilitySettings() {
        #if os(macOS)
        prefersReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        prefersReducedTransparency = NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        prefersIncreasedContrast = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
        #endif
    }
}
