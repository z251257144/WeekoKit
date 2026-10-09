import SwiftUI

@MainActor
public struct WeekoPermissionSettingsItem: Identifiable {
  public let id: String
  public let icon: String
  public let tint: Color
  public let title: String
  public let subtitle: String
  public let coordinator: WeekoPermissionCoordinator

  private let onOpen: () -> Void

  public init(
    id: String,
    icon: String,
    tint: Color,
    title: String,
    subtitle: String,
    coordinator: WeekoPermissionCoordinator,
    onOpen: @escaping () -> Void
  ) {
    self.id = id
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.coordinator = coordinator
    self.onOpen = onOpen
  }

  func open() {
    onOpen()
  }
}

extension WeekoPermissionSettingsItem {
  public static func weekoDefault(
    kind: WeekoPermissionKind,
    tint: Color,
    coordinator: WeekoPermissionCoordinator,
    onOpen: @escaping () -> Void
  ) -> WeekoPermissionSettingsItem {
    WeekoPermissionSettingsItem(
      id: kind.rawValue,
      icon: kind.systemImage,
      tint: tint,
      title: kind.title,
      subtitle: kind.subtitle,
      coordinator: coordinator,
      onOpen: onOpen
    )
  }
}
