import SwiftUI

public struct WeekoMacTheme {
  public var accentColor: Color
  public var windowCornerRadius: CGFloat
  public var componentCornerRadius: CGFloat
  public var sidebarWidth: CGFloat
  public var trailingColumnWidth: ClosedRange<CGFloat>

  public init(
    accentColor: Color,
    windowCornerRadius: CGFloat = 22,
    componentCornerRadius: CGFloat = 8,
    sidebarWidth: CGFloat = 220,
    trailingColumnWidth: ClosedRange<CGFloat> = 112...210
  ) {
    self.accentColor = accentColor
    self.windowCornerRadius = windowCornerRadius
    self.componentCornerRadius = componentCornerRadius
    self.sidebarWidth = sidebarWidth
    self.trailingColumnWidth = trailingColumnWidth
  }

  public static let `default` = WeekoMacTheme(
    accentColor: Color.accentColor
  )
}

private struct WeekoMacThemeKey: EnvironmentKey {
  static let defaultValue = WeekoMacTheme.default
}

extension EnvironmentValues {
  public var weekoMacTheme: WeekoMacTheme {
    get { self[WeekoMacThemeKey.self] }
    set { self[WeekoMacThemeKey.self] = newValue }
  }
}

extension View {
  public func weekoMacTheme(_ theme: WeekoMacTheme) -> some View {
    environment(\.weekoMacTheme, theme)
      .tint(theme.accentColor)
  }
}
