import AppKit
import SwiftUI

public struct WeekoMenuHeader<Status: View>: View {
  private let applicationName: String
  private let applicationIcon: NSImage?
  private let subtitle: String?
  private let status: Status

  public init(
    applicationName: String,
    applicationIcon: NSImage? = nil,
    subtitle: String? = nil,
    @ViewBuilder status: () -> Status
  ) {
    self.applicationName = applicationName
    self.applicationIcon = applicationIcon
    self.subtitle = subtitle
    self.status = status()
  }

  public var body: some View {
    HStack(spacing: 11) {
      Image(nsImage: applicationIcon ?? NSApplication.shared.applicationIconImage)
        .resizable()
        .frame(width: 39, height: 39)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.11), radius: 4, x: 0, y: 2)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 3) {
        Text(applicationName)
          .font(.system(size: 14, weight: .bold))
          .lineLimit(1)

        if let subtitle, !subtitle.isEmpty {
          Text(subtitle)
            .font(.system(size: 10.5, weight: .medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
      }

      Spacer(minLength: 8)
      status
    }
  }
}

extension WeekoMenuHeader where Status == EmptyView {
  public init(
    applicationName: String,
    applicationIcon: NSImage? = nil,
    subtitle: String? = nil
  ) {
    self.init(
      applicationName: applicationName,
      applicationIcon: applicationIcon,
      subtitle: subtitle
    ) {
      EmptyView()
    }
  }
}

public struct WeekoMenuStatusButton: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isHovered = false

  private let title: String
  private let tint: Color
  private let action: () -> Void

  public init(
    title: String,
    tint: Color,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.tint = tint
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        Circle()
          .fill(tint)
          .frame(width: 7, height: 7)

        Text(title)
          .font(.system(size: 10.5, weight: .semibold))
          .lineLimit(1)
          .minimumScaleFactor(0.82)
      }
      .foregroundStyle(tint)
      .padding(.horizontal, 9)
      .frame(height: 25)
      .background(tint.opacity(isHovered ? 0.14 : 0.09), in: Capsule())
      .overlay {
        Capsule().strokeBorder(tint.opacity(0.12), lineWidth: 0.5)
      }
    }
    .buttonStyle(.plain)
    .onHover { isHovered = $0 }
    .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: isHovered)
    .help(title)
    .accessibilityLabel(title)
  }

}
