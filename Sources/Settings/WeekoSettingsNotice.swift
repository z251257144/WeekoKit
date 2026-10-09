import SwiftUI

public struct WeekoSettingsNotice<Actions: View>: View {
  private let icon: String
  private let tint: Color
  private let message: String
  private let actions: Actions

  public init(
    icon: String,
    tint: Color,
    message: String,
    @ViewBuilder actions: () -> Actions
  ) {
    self.icon = icon
    self.tint = tint
    self.message = message
    self.actions = actions()
  }

  public var body: some View {
    HStack(spacing: 10) {
      Image(systemName: icon)
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(tint)
        .accessibilityHidden(true)

      Text(message)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(Color.primary.opacity(0.82))
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 10)
      actions
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 9)
    .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .strokeBorder(tint.opacity(0.14), lineWidth: 0.8)
    }
  }
}

extension WeekoSettingsNotice where Actions == EmptyView {
  public init(icon: String, tint: Color, message: String) {
    self.init(icon: icon, tint: tint, message: message) {
      EmptyView()
    }
  }
}
