import SwiftUI

public struct WeekoSettingsActionButtonStyle: ButtonStyle {
  public let tint: Color

  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  public init(tint: Color) {
    self.tint = tint
  }

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: WeekoSettingMetrics.subtitleFontSize, weight: .semibold))
      .lineLimit(1)
      .minimumScaleFactor(0.86)
      .foregroundStyle(isEnabled ? Color.white : Color.secondary)
      .padding(.horizontal, 13)
      .frame(height: WeekoSettingMetrics.actionHeight)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(
            isEnabled
              ? tint.opacity(configuration.isPressed ? 0.74 : (isHovered ? 1 : 0.92))
              : Color.primary.opacity(0.06)
          )
      )
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
      .opacity(isEnabled ? 1 : 0.5)
      .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
      .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovered)
      .onHover { isHovered = $0 }
  }
}

public struct WeekoSettingsIconActionButtonStyle: ButtonStyle {
  public let tint: Color

  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  public init(tint: Color) {
    self.tint = tint
  }

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 12, weight: .semibold))
      .foregroundStyle(isEnabled ? tint : Color.secondary)
      .frame(width: 30, height: 30)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(
            isEnabled
              ? tint.opacity(configuration.isPressed ? 0.18 : (isHovered ? 0.13 : 0.09))
              : Color.primary.opacity(0.05)
          )
      )
      .overlay {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .strokeBorder(tint.opacity(isEnabled ? 0.14 : 0.05), lineWidth: 0.8)
      }
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .opacity(isEnabled ? 1 : 0.55)
      .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
      .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovered)
      .onHover { isHovered = $0 }
  }
}

public struct WeekoCircularIconButtonStyle: ButtonStyle {
  @Environment(\.weekoMacTheme) private var theme
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(
        isEnabled
          ? (configuration.isPressed
            ? theme.accentColor
            : (isHovered ? Color.primary : Color.secondary))
          : Color.secondary.opacity(0.55)
      )
      .background(
        Circle().fill(
          Color.primary.opacity(configuration.isPressed ? 0.15 : (isHovered ? 0.08 : 0.045))
        )
      )
      .overlay(
        Circle().strokeBorder(Color.primary.opacity(isHovered ? 0.09 : 0.045), lineWidth: 0.7)
      )
      .scaleEffect(configuration.isPressed ? 0.94 : 1)
      .onHover { isHovered = $0 }
      .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
      .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovered)
  }
}
