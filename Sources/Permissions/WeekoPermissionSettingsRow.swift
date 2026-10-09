import SwiftUI

@MainActor
struct WeekoPermissionSettingsRow: View {
  let item: WeekoPermissionSettingsItem
  let needsPermissionTitle: String
  let grantedTitle: String
  let unavailableTitle: String

  @ObservedObject private var coordinator: WeekoPermissionCoordinator

  init(
    item: WeekoPermissionSettingsItem,
    needsPermissionTitle: String,
    grantedTitle: String,
    unavailableTitle: String
  ) {
    self.item = item
    self.needsPermissionTitle = needsPermissionTitle
    self.grantedTitle = grantedTitle
    self.unavailableTitle = unavailableTitle
    _coordinator = ObservedObject(wrappedValue: item.coordinator)
  }

  var body: some View {
    WeekoSettingRow(
      icon: item.icon,
      tint: item.tint,
      title: item.title,
      subtitle: item.subtitle,
      trailing: {
      switch coordinator.status {
      case .authorized:
        Button(action: item.open) {
          permissionStatus(
            title: grantedTitle,
            icon: "checkmark.circle.fill",
            tint: .green
          )
        }
        .buttonStyle(WeekoPermissionStatusButtonStyle())
      case .unavailable:
        permissionStatus(
          title: unavailableTitle,
          icon: "xmark.circle.fill",
          tint: .red
        )
      case .notDetermined, .denied, .restricted:
        Button(action: item.open) {
          Label(needsPermissionTitle, systemImage: "circle.fill")
        }
        .buttonStyle(WeekoPermissionActionButtonStyle(tint: .orange))
      }
      }
    )
  }

  private func permissionStatus(title: String, icon: String, tint: Color) -> some View {
    Label(title, systemImage: icon)
      .font(.system(size: 11, weight: .semibold))
      .lineLimit(1)
      .padding(.horizontal, 11)
      .frame(height: 28)
      .foregroundStyle(tint)
      .background(tint.opacity(0.11), in: Capsule(style: .continuous))
      .overlay {
        Capsule(style: .continuous)
          .strokeBorder(tint.opacity(0.18), lineWidth: 0.8)
      }
  }
}

private struct WeekoPermissionActionButtonStyle: ButtonStyle {
  let tint: Color

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 11, weight: .semibold))
      .lineLimit(1)
      .padding(.horizontal, 11)
      .frame(height: 28)
      .foregroundStyle(tint)
      .symbolRenderingMode(.hierarchical)
      .background(
        tint.opacity(configuration.isPressed ? 0.18 : (isHovered ? 0.15 : 0.11)),
        in: Capsule(style: .continuous)
      )
      .overlay {
        Capsule(style: .continuous)
          .strokeBorder(tint.opacity(0.18), lineWidth: 0.8)
      }
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
      .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
      .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovered)
      .onHover { isHovered = $0 }
  }
}

private struct WeekoPermissionStatusButtonStyle: ButtonStyle {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.72 : (isHovered ? 0.86 : 1))
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
      .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
      .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isHovered)
      .onHover { isHovered = $0 }
  }
}
