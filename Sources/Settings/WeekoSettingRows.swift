import SwiftUI

public struct WeekoSettingRowLabel<TitleAccessory: View>: View {
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
        Image(systemName: icon)
          .font(.system(size: WeekoSettingMetrics.iconSize, weight: .semibold))
          .foregroundStyle(tint)
          .frame(
            width: WeekoSettingMetrics.iconContainerSize,
            height: WeekoSettingMetrics.iconContainerSize
          )
          .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .fill(tint.opacity(0.12))
          )
          .accessibilityHidden(true)
      }

      VStack(alignment: .leading, spacing: WeekoSettingMetrics.labelSpacing) {
        HStack(alignment: .center, spacing: 6) {
          Text(title)
            .font(.system(size: WeekoSettingMetrics.titleFontSize, weight: .medium))
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)

          titleAccessory
            .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if let subtitle, !subtitle.isEmpty {
          Text(subtitle)
            .font(.system(size: WeekoSettingMetrics.subtitleFontSize))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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
  @Environment(\.weekoMacTheme) private var theme

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
      HStack(alignment: .center, spacing: 16) {
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
            width: theme.trailingColumnWidth.upperBound,
            alignment: .trailing
          )
          .layoutPriority(2)
      }
      .padding(.vertical, WeekoSettingMetrics.rowVerticalPadding)
      .padding(.horizontal, 6)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
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
  private let icon: String
  private let tint: Color
  private let title: String
  private let subtitle: String
  private let trailing: Trailing

  public init(
    icon: String,
    tint: Color,
    title: String,
    subtitle: String = "",
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.trailing = trailing()
  }

  public var body: some View {
    WeekoSettingRow(
      icon: icon,
      tint: tint,
      title: title,
      subtitle: subtitle,
      trailing: {
      trailing
      }
    )
  }
}

public struct WeekoSettingToggleRow: View {
  @Environment(\.weekoMacTheme) private var theme
  @Binding private var isOn: Bool

  private let icon: String
  private let tint: Color
  private let title: String
  private let subtitle: String

  public init(
    isOn: Binding<Bool>,
    icon: String,
    tint: Color,
    title: String,
    subtitle: String = ""
  ) {
    _isOn = isOn
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
  }

  public var body: some View {
    Toggle(isOn: $isOn) {
      WeekoSettingRowLabel(
        icon: icon,
        tint: tint,
        title: title,
        subtitle: subtitle
      )
    }
    .toggleStyle(.switch)
    .tint(theme.accentColor)
    .controlSize(.small)
    .padding(.vertical, WeekoSettingMetrics.rowVerticalPadding)
    .accessibilityLabel(title)
  }
}

public struct WeekoSettingDivider: View {
  private let isIndented: Bool

  public init(isIndented: Bool = false) {
    self.isIndented = isIndented
  }

  public var body: some View {
    Divider()
      .opacity(0.8)
      .padding(
        .leading,
        isIndented ? WeekoSettingMetrics.iconContainerSize + WeekoSettingMetrics.rowSpacing : 0
      )
  }
}
