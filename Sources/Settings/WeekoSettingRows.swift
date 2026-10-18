import SwiftUI

public struct WeekoSettingRowLabel<TitleAccessory: View>: View {
  @Environment(\.weekoTheme) private var theme
  @Environment(\.weekoVisualEnhancement) private var enhancement
  
  public let icon: String?
  public let tint: Color
  public let title: String
  public let subtitle: String?
  private let titleAccessory: TitleAccessory

  public init(
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil,
    @ViewBuilder titleAccessory: () -> TitleAccessory
  ) {
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.titleAccessory = titleAccessory()
  }

  public var body: some View {
    HStack(
      alignment: subtitle?.isEmpty != false ? .center : .top,
      spacing: WeekoSettingMetrics.rowSpacing
    ) {
      if let icon, !icon.isEmpty {
        iconView
      }

      VStack(alignment: .leading, spacing: WeekoSettingMetrics.labelSpacing) {
        HStack(alignment: .center, spacing: theme.spacingInline) {
          Text(title)
            .font(.system(size: WeekoSettingMetrics.titleFontSize, weight: .medium))
            .foregroundStyle(theme.contentPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)

          titleAccessory
            .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if let subtitle, !subtitle.isEmpty {
          Text(subtitle)
            .font(.system(size: WeekoSettingMetrics.subtitleFontSize))
            .foregroundStyle(theme.contentSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  @ViewBuilder
  private var iconView: some View {
    if enhancement.contains(.iconWells) {
      ZStack {
        LinearGradient(
          colors: [
            tint.opacity(0.15),
            tint.opacity(0.05)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        
        Image(systemName: icon!)
          .font(.system(size: WeekoSettingMetrics.iconSize, weight: .semibold))
          .foregroundStyle(tint)
      }
      .frame(
        width: WeekoSettingMetrics.iconContainerSize,
        height: WeekoSettingMetrics.iconContainerSize
      )
      .clipShape(RoundedRectangle(cornerRadius: theme.radiusSmall + 2))
      .weekoBorder(tint.opacity(0.2), width: 0.5, radius: theme.radiusSmall + 2)
      .accessibilityHidden(true)
    } else {
      Image(systemName: icon!)
        .font(.system(size: WeekoSettingMetrics.iconSize, weight: .semibold))
        .foregroundStyle(tint)
        .frame(
          width: WeekoSettingMetrics.iconContainerSize,
          height: WeekoSettingMetrics.iconContainerSize
        )
        .background(
          RoundedRectangle(cornerRadius: theme.radiusSmall + 2, style: .continuous)
            .fill(tint.opacity(0.12))
        )
        .accessibilityHidden(true)
    }
  }
}

extension WeekoSettingRowLabel where TitleAccessory == EmptyView {
  public init(
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil
  ) {
    self.init(icon: icon, tint: tint, title: title, subtitle: subtitle) {
      EmptyView()
    }
  }
}

public struct WeekoSettingRow<Trailing: View>: View {
  @Environment(\.weekoMacTheme) private var macTheme
  @Environment(\.weekoTheme) private var theme
  @Environment(\.weekoVisualEnhancement) private var enhancement
  @State private var isHovered = false

  private let icon: String?
  private let tint: Color
  private let title: String
  private let subtitle: String?
  private let titleAccessory: AnyView
  private let trailing: Trailing

  public init(
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    titleAccessory = AnyView(EmptyView())
    self.trailing = trailing()
  }

  public init<TitleAccessory: View>(
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil,
    @ViewBuilder titleAccessory: () -> TitleAccessory,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.titleAccessory = AnyView(titleAccessory())
    self.trailing = trailing()
  }

  public var body: some View {
    if Trailing.self == EmptyView.self {
      WeekoSettingRowLabel(
        icon: icon,
        tint: tint,
        title: title,
        subtitle: subtitle
      ) {
        titleAccessory
      }
      .padding(.vertical, WeekoSettingMetrics.rowVerticalPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
    } else {
      HStack(alignment: .center, spacing: theme.spacingSection) {
        WeekoSettingRowLabel(
          icon: icon,
          tint: tint,
          title: title,
          subtitle: subtitle
        ) {
          titleAccessory
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)

        trailing
          .frame(
            width: macTheme.trailingColumnWidth.upperBound,
            alignment: .trailing
          )
          .layoutPriority(2)
      }
      .padding(.vertical, WeekoSettingMetrics.rowVerticalPadding)
      .padding(.horizontal, theme.spacingInset / 2)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(rowBackground)
//      .contentShape(Rectangle())
//      .conditionalModifier(enhancement.contains(.hover)) { view in
//        view.onHover { hovering in
//          isHovered = hovering
//        }
//      }
    }
  }
  
  @ViewBuilder
  private var rowBackground: some View {
//    if enhancement.contains(.hover) {
//      RoundedRectangle(cornerRadius: theme.radiusSmall)
//        .fill(isHovered ? theme.interactiveHover : Color.clear)
//        .weekoAnimation(
//          duration: theme.animationFast,
//          value: isHovered,
//          prefersReducedMotion: theme.prefersReducedMotion
//        )
//    }
  }
}

extension WeekoSettingRow where Trailing == EmptyView {
  public init(
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil
  ) {
    self.init(icon: icon, tint: tint, title: title, subtitle: subtitle) {
      EmptyView()
    }
  }

  public init<TitleAccessory: View>(
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil,
    @ViewBuilder titleAccessory: () -> TitleAccessory
  ) {
    self.init(
      icon: icon,
      tint: tint,
      title: title,
      subtitle: subtitle,
      titleAccessory: titleAccessory
    ) {
      EmptyView()
    }
  }
}

public struct WeekoSettingActionRow<Trailing: View>: View {
  @Environment(\.weekoTheme) private var theme
  
  private let icon: String
  private let tint: Color
  private let title: String
  private let subtitle: String
  private let trailing: Trailing
  private let action: () -> Void

  public init(
    icon: String,
    tint: Color = .secondary,
    title: String,
    subtitle: String,
    @ViewBuilder trailing: () -> Trailing = { EmptyView() },
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.trailing = trailing()
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      WeekoSettingRow(
        icon: icon,
        tint: tint,
        title: title,
        subtitle: subtitle,
        trailing: { trailing }
      )
    }
    .buttonStyle(.plain)
  }
}

extension WeekoSettingActionRow where Trailing == EmptyView {
  public init(
    icon: String,
    tint: Color = .secondary,
    title: String,
    subtitle: String,
    action: @escaping () -> Void
  ) {
    self.init(icon: icon, tint: tint, title: title, subtitle: subtitle, trailing: { EmptyView() }, action: action)
  }
}

public struct WeekoSettingToggleRow: View {
  @Binding private var isOn: Bool
  private let icon: String?
  private let tint: Color
  private let title: String
  private let subtitle: String?
  
  public init(
    isOn: Binding<Bool>,
    icon: String? = nil,
    tint: Color = .secondary,
    title: String,
    subtitle: String? = nil
  ) {
    self._isOn = isOn
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
  }
  
  public var body: some View {
    WeekoSettingRow(
      icon: icon,
      tint: tint,
      title: title,
      subtitle: subtitle,
      trailing: {
        Toggle("", isOn: $isOn)
          .labelsHidden()
      }
    )
  }
}

public struct WeekoSettingDivider: View {
  @Environment(\.weekoTheme) private var theme
  
  public init() {}
  
  public var body: some View {
    Divider()
      .background(theme.borderSecondary)
      .padding(.vertical, theme.spacingStack / 2)
  }
}
