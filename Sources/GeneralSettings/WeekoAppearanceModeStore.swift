import AppKit
import Combine
import Foundation

/// 外观模式设置存储
@MainActor
public final class WeekoAppearanceModeStore: ObservableObject {
  private static let defaultsKey = "WeekoAppearanceModeSelection"
  
  @Published public private(set) var selectedMode: WeekoAppearanceMode
  @Published public private(set) var effectiveAppearance: NSAppearance?
  
  private let defaults: UserDefaults
  
  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    
    if let rawValue = defaults.string(forKey: Self.defaultsKey),
       let mode = WeekoAppearanceMode(rawValue: rawValue) {
      self.selectedMode = mode
    } else {
      self.selectedMode = .system
    }
    
    self.effectiveAppearance = Self.resolveAppearance(for: selectedMode)
  }
  
  /// 设置外观模式
  public func setMode(_ mode: WeekoAppearanceMode) {
    selectedMode = mode
    defaults.set(mode.rawValue, forKey: Self.defaultsKey)
    effectiveAppearance = Self.resolveAppearance(for: mode)
    
    // 立即应用到当前应用
    NSApp.appearance = effectiveAppearance
  }
  
  /// 根据模式解析实际外观
  private static func resolveAppearance(for mode: WeekoAppearanceMode) -> NSAppearance? {
    switch mode {
    case .system:
      return nil  // nil 表示跟随系统
    case .light:
      return NSAppearance(named: .aqua)
    case .dark:
      return NSAppearance(named: .darkAqua)
    }
  }
  
  /// 应用保存的外观设置到当前应用
  public func applyToApplication() {
    NSApp.appearance = effectiveAppearance
  }
}
