import SwiftUI

/// Defines levels of visual detail and interaction feedback beyond basic theme colors.
/// Higher levels add more visual flourish but may distract some users or reduce performance.
public struct WeekoVisualEnhancement: OptionSet, Hashable {
  public let rawValue: Int
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  /// No extra visual effects; cleanest baseline
  public static let minimal = WeekoVisualEnhancement([])
  
  /// Subtle hover states on interactive rows
  public static let hover = WeekoVisualEnhancement(rawValue: 1 << 0)
  
  /// Icon backgrounds with soft gradients and borders
  public static let iconWells = WeekoVisualEnhancement(rawValue: 1 << 1)
  
  /// Subtle animations (respects reduce motion)
  public static let animations = WeekoVisualEnhancement(rawValue: 1 << 2)
  
  /// Default set: hover + icon wells
  public static let standard: WeekoVisualEnhancement = [.hover, .iconWells]
  
  /// Full experience: all enhancements
  public static let enhanced: WeekoVisualEnhancement = [.hover, .iconWells, .animations]
}

extension View {
  /// Set the visual enhancement level for this view hierarchy
  public func weekoVisualEnhancement(_ level: WeekoVisualEnhancement) -> some View {
    environment(\.weekoVisualEnhancement, level)
  }
}

private struct WeekoVisualEnhancementKey: EnvironmentKey {
  static let defaultValue: WeekoVisualEnhancement = .standard
}

extension EnvironmentValues {
  public var weekoVisualEnhancement: WeekoVisualEnhancement {
    get { self[WeekoVisualEnhancementKey.self] }
    set { self[WeekoVisualEnhancementKey.self] = newValue }
  }
}
