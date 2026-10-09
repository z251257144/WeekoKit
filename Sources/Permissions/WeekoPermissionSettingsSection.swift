import SwiftUI

@MainActor
public struct WeekoPermissionSettingsSection: View {
  private let title: String
  private let icon: String
  private let items: [WeekoPermissionSettingsItem]
  private let needsPermissionTitle: String
  private let grantedTitle: String
  private let unavailableTitle: String

  public init(
    _ title: String = WeekoLocalization.packageString("weeko_permissions_section_title"),
    icon: String = "lock.shield",
    items: [WeekoPermissionSettingsItem],
    needsPermissionTitle: String = WeekoLocalization.packageString(
      "weeko_permissions_needs_permission"
    ),
    grantedTitle: String = WeekoLocalization.packageString("weeko_permissions_granted"),
    unavailableTitle: String = WeekoLocalization.packageString("weeko_permissions_unavailable")
  ) {
    self.title = title
    self.icon = icon
    self.items = items
    self.needsPermissionTitle = needsPermissionTitle
    self.grantedTitle = grantedTitle
    self.unavailableTitle = unavailableTitle
  }

  public var body: some View {
    WeekoSettingSection(title, icon: icon) {
      ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
        WeekoPermissionSettingsRow(
          item: item,
          needsPermissionTitle: needsPermissionTitle,
          grantedTitle: grantedTitle,
          unavailableTitle: unavailableTitle
        )

        if index < items.count - 1 {
          WeekoSettingDivider()
        }
      }
    }
    .task {
      let coordinators = items.map(\.coordinator)
      await withTaskGroup(of: Void.self) { group in
        for coordinator in coordinators {
          group.addTask {
            _ = await coordinator.refresh()
          }
        }
      }
    }
  }
}
