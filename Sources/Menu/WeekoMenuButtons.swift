import AppKit
import SwiftUI

public struct WeekoMenuPrimaryButton: View {
  @Environment(\.weekoMacTheme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  private let title: String
  private let icon: String
  private let shortcut: String?
  private let tint: Color?
  private let action: () -> Void

  public init(
    title: String,
    icon: String,
    shortcut: String? = nil,
    tint: Color? = nil,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.shortcut = shortcut
    self.tint = tint
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 9) {
        Image(systemName: icon)
          .font(.system(size: 13, weight: .semibold))
          .frame(width: 18)

        Text(title)
          .font(.system(size: 12.5, weight: .semibold))
          .lineLimit(1)

        Spacer(minLength: 8)
        WeekoMenuShortcutBadge(text: shortcut)
      }
      .foregroundStyle(.white)
      .padding(.horizontal, 11)
      .frame(maxWidth: .infinity)
      .frame(height: 38)
      .background(buttonShape.fill(effectiveTint.opacity(isHovered ? 0.96 : 0.88)))
      .overlay {
        buttonShape.strokeBorder(Color.white.opacity(0.23), lineWidth: 0.7)
      }
      .offset(y: isHovered && !reduceMotion ? -1 : 0)
      .contentShape(buttonShape)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: isHovered)
    .help(title)
  }

  private var effectiveTint: Color {
    tint ?? theme.accentColor
  }

  private var buttonShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 8, style: .continuous)
  }

}

public struct WeekoMenuActionButton: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  private let title: String
  private let icon: String
  private let shortcut: String?
  private let tint: Color
  private let action: () -> Void

  public init(
    title: String,
    icon: String,
    shortcut: String? = nil,
    tint: Color,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.shortcut = shortcut
    self.tint = tint
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 9) {
        Image(systemName: icon)
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(tint)
          .frame(width: 27, height: 27)
          .background(iconShape.fill(tint.opacity(isHovered ? 0.19 : 0.12)))
          .overlay {
            iconShape.strokeBorder(tint.opacity(isHovered ? 0.28 : 0.13), lineWidth: 0.7)
          }

        VStack(alignment: .leading, spacing: 3) {
          Text(title)
            .font(.system(size: 11.5, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.75)

          if let shortcut, !shortcut.isEmpty {
            Text(shortcut)
              .font(.system(size: 9.5, weight: .medium, design: .rounded))
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
        }

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 10)
      .frame(maxWidth: .infinity)
      .frame(height: 52)
      .background(buttonBackground)
      .overlay {
        buttonShape.strokeBorder(
          isHovered ? tint.opacity(0.28) : Color.primary.opacity(0.07),
          lineWidth: 0.7
        )
      }
      .shadow(color: isHovered ? tint.opacity(0.08) : .clear, radius: 4, x: 0, y: 2)
      .offset(y: isHovered && !reduceMotion ? -1 : 0)
      .contentShape(buttonShape)
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: isHovered)
    .help(title)
  }

  private var iconShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 6, style: .continuous)
  }

  private var buttonShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 8, style: .continuous)
  }

  private var buttonBackground: some View {
    buttonShape.fill(
      LinearGradient(
        colors: [
          .weekoMenuInversePrimary.opacity(isHovered ? 0.74 : 0.52),
          tint.opacity(isHovered ? 0.075 : 0.035),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
  }
}

public struct WeekoMenuTileButton<Badge: View>: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  private let title: String
  private let icon: String
  private let tint: Color
  private let role: ButtonRole?
  private let badge: Badge
  private let action: () -> Void

  public init(
    title: String,
    icon: String,
    tint: Color,
    role: ButtonRole? = nil,
    @ViewBuilder badge: () -> Badge,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.tint = tint
    self.role = role
    self.badge = badge()
    self.action = action
  }

  public var body: some View {
    Button(role: role, action: action) {
      VStack(spacing: 6) {
        Image(systemName: icon)
          .font(.system(size: 13, weight: .semibold))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(tint)
          .frame(width: 27, height: 27)
          .background(iconShape.fill(tint.opacity(isHovered ? 0.19 : 0.12)))
          .overlay {
            iconShape.strokeBorder(tint.opacity(isHovered ? 0.26 : 0.12), lineWidth: 0.7)
          }

        Text(title)
          .font(.system(size: 10.5, weight: .medium))
          .lineLimit(1)
          .minimumScaleFactor(0.72)
      }
      .foregroundStyle(isHovered ? Color.primary.opacity(0.90) : Color.primary.opacity(0.68))
      .frame(maxWidth: .infinity)
      .frame(height: 59)
      .background(buttonBackground)
      .overlay {
        buttonShape.strokeBorder(
          isHovered ? tint.opacity(0.22) : Color.primary.opacity(0.06),
          lineWidth: 0.7
        )
      }
      .shadow(color: isHovered ? tint.opacity(0.10) : .clear, radius: 4, x: 0, y: 2)
      .offset(y: isHovered && !reduceMotion ? -1 : 0)
      .contentShape(buttonShape)
      .overlay(alignment: .topTrailing) {
        badge.padding(5)
      }
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: isHovered)
    .help(title)
  }

  private var iconShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 7, style: .continuous)
  }

  private var buttonShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 9, style: .continuous)
  }

  private var buttonBackground: some View {
    buttonShape.fill(
      LinearGradient(
        colors: [
          .weekoMenuInversePrimary.opacity(isHovered ? 0.72 : 0.48),
          tint.opacity(isHovered ? 0.065 : 0.025),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
  }
}

private extension Color {
  static let weekoMenuInversePrimary = Color(
    NSColor(name: nil) { appearance in
      appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .black : .white
    }
  )
}

extension WeekoMenuTileButton where Badge == EmptyView {
  public init(
    title: String,
    icon: String,
    tint: Color,
    role: ButtonRole? = nil,
    action: @escaping () -> Void
  ) {
    self.init(title: title, icon: icon, tint: tint, role: role, badge: EmptyView.init, action: action)
  }
}

public struct WeekoMenuShortcutBadge: View {
  private let text: String?

  public init(text: String?) {
    self.text = text
  }

  @ViewBuilder
  public var body: some View {
    if let text, !text.isEmpty {
      Text(text)
        .font(.system(size: 10, weight: .medium, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.90))
        .padding(.horizontal, 6)
        .frame(height: 18)
        .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: 5, style: .continuous)
            .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        }
    }
  }
}
