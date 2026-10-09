import SwiftUI

public struct WeekoSettingsStatusPill: View {
  public let title: String
  public let icon: String
  public let tint: Color
  public let compact: Bool

  public init(
    title: String,
    icon: String,
    tint: Color,
    compact: Bool = false
  ) {
    self.title = title
    self.icon = icon
    self.tint = tint
    self.compact = compact
  }

  public var body: some View {
    HStack(spacing: compact ? 3 : 4) {
      Image(systemName: icon)
      Text(title)
    }
      .font(.system(size: compact ? 11 : 12, weight: .semibold))
      .lineLimit(1)
      .minimumScaleFactor(0.78)
      .fixedSize(horizontal: true, vertical: false)
      .padding(.horizontal, compact ? 9 : 11)
      .padding(.vertical, compact ? 4 : 5)
      .foregroundStyle(tint)
      .background(Capsule(style: .continuous).fill(tint.opacity(0.10)))
      .overlay(
        Capsule(style: .continuous)
          .strokeBorder(tint.opacity(0.16), lineWidth: 0.8)
      )
      .accessibilityElement(children: .combine)
  }
}
