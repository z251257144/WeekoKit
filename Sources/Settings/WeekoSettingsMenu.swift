import AppKit
import SwiftUI

public struct WeekoSettingsNavigationItem<ID: Hashable>: Identifiable {
  public let id: ID
  public let title: String
  public let systemImage: String
  public let tint: Color

  public init(id: ID, title: String, systemImage: String, tint: Color) {
    self.id = id
    self.title = title
    self.systemImage = systemImage
    self.tint = tint
  }
}

public struct WeekoSettingsNavigationGroup<ID: Hashable>: Identifiable {
  public let id: String
  public let title: String?
  public let placement: Placement
  public let items: [WeekoSettingsNavigationItem<ID>]

  public enum Placement {
    case primary
    case bottom
  }

  public init(
    id: String,
    title: String? = nil,
    placement: Placement = .primary,
    items: [WeekoSettingsNavigationItem<ID>]
  ) {
    self.id = id
    self.title = title
    self.placement = placement
    self.items = items
  }
}

public struct WeekoSettingsMenu<ID: Hashable, Accessory: View>: View {
  @Environment(\.weekoMacTheme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding private var selection: ID
  @State private var hoveredItem: ID?

  private let applicationName: String
  private let applicationIcon: NSImage?
  private let groups: [WeekoSettingsNavigationGroup<ID>]
  private let navigationAccessory: (ID) -> Accessory

  public init(
    applicationName: String,
    applicationIcon: NSImage? = nil,
    groups: [WeekoSettingsNavigationGroup<ID>],
    selection: Binding<ID>,
    @ViewBuilder navigationAccessory: @escaping (ID) -> Accessory
  ) {
    self.applicationName = applicationName
    self.applicationIcon = applicationIcon
    self.groups = groups
    _selection = selection
    self.navigationAccessory = navigationAccessory
  }

  public var body: some View {
    VStack(spacing: 0) {
      appHeader.padding(.bottom, 26)

      ForEach(primaryGroups) { group in
        menuGroup(group)
      }

      Spacer(minLength: 0)

      ForEach(bottomGroups) { group in
        menuGroup(group)
      }
    }
    .padding(EdgeInsets(top: 28, leading: 16, bottom: 18, trailing: 16))
    .frame(width: theme.sidebarWidth)
    .background(theme.accentColor.opacity(0.04))
  }

  private var appHeader: some View {
    VStack(spacing: 9) {
      Image(nsImage: applicationIcon ?? NSApplication.shared.applicationIconImage)
        .resizable()
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        .accessibilityHidden(true)

      Text(applicationName)
        .font(.system(size: 17, weight: .bold))
        .lineLimit(1)
        .minimumScaleFactor(0.82)
    }
    .frame(maxWidth: .infinity)
  }

  private func menuGroup(_ group: WeekoSettingsNavigationGroup<ID>) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      if let title = group.title {
        Text(title)
          .font(.system(size: 10, weight: .bold))
          .foregroundStyle(.tertiary)
          .textCase(.uppercase)
          .padding(.leading, 12)
          .padding(.bottom, 2)
      }

      ForEach(group.items) { item in
        menuButton(item)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, group.placement == .bottom ? 12 : 16)
  }

  private func menuButton(_ item: WeekoSettingsNavigationItem<ID>) -> some View {
    let isSelected = selection == item.id
    let isHovered = hoveredItem == item.id

    return Button {
      selection = item.id
    } label: {
      HStack(spacing: 11) {
        Image(systemName: item.systemImage)
          .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
          .symbolRenderingMode(.hierarchical)
          .frame(width: 20)

        Text(item.title)
          .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
          .lineLimit(1)
          .minimumScaleFactor(0.78)

        navigationAccessory(item.id)

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 11)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: 39)
      .foregroundStyle(isSelected ? item.tint : Color.primary.opacity(0.72))
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(isSelected ? item.tint.opacity(0.11) : Color.primary.opacity(isHovered ? 0.045 : 0))
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .onHover { hoveredItem = $0 ? item.id : nil }
    .animation(reduceMotion ? nil : .easeInOut(duration: 0.14), value: isSelected)
    .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: isHovered)
  }

  private var primaryGroups: [WeekoSettingsNavigationGroup<ID>] {
    groups.filter { $0.placement == .primary }
  }

  private var bottomGroups: [WeekoSettingsNavigationGroup<ID>] {
    groups.filter { $0.placement == .bottom }
  }
}

extension WeekoSettingsMenu where Accessory == EmptyView {
  public init(
    applicationName: String,
    applicationIcon: NSImage? = nil,
    groups: [WeekoSettingsNavigationGroup<ID>],
    selection: Binding<ID>
  ) {
    self.init(
      applicationName: applicationName,
      applicationIcon: applicationIcon,
      groups: groups,
      selection: selection,
      navigationAccessory: { _ in EmptyView() }
    )
  }
}
