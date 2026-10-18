import Foundation

/// 应用外观模式
public enum WeekoAppearanceMode: String, CaseIterable, Identifiable {
  /// 跟随系统
  case system
  /// 浅色模式
  case light
  /// 深色模式
  case dark
  
  public var id: String { rawValue }
  
  /// 本地化显示名称
  public var localizedName: String {
    switch self {
    case .system:
      return WeekoLocalization.packageString("weeko_appearance_mode_system")
    case .light:
      return WeekoLocalization.packageString("weeko_appearance_mode_light")
    case .dark:
      return WeekoLocalization.packageString("weeko_appearance_mode_dark")
    }
  }
  
  /// 本地化键
  var localizationKey: String {
    switch self {
    case .system:
      return "weeko_appearance_mode_system"
    case .light:
      return "weeko_appearance_mode_light"
    case .dark:
      return "weeko_appearance_mode_dark"
    }
  }
  
  /// SF Symbol 图标
  public var symbolName: String {
    switch self {
    case .system:
      return "circle.lefthalf.filled"
    case .light:
      return "sun.max.fill"
    case .dark:
      return "moon.fill"
    }
  }
  
  /// 图标名称（别名）
  var iconName: String {
    symbolName
  }
}
