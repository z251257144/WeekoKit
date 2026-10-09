import AppKit
import SwiftUI

public struct WeekoAboutRow: Identifiable {
  public let id: String
  public let icon: String
  public let tint: Color
  public let title: String
  public let subtitle: String
  public let url: URL?

  public init(
    id: String? = nil,
    icon: String,
    tint: Color,
    title: String,
    subtitle: String,
    url: URL? = nil
  ) {
    self.id = id ?? url?.absoluteString ?? "\(icon):\(title)"
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.url = url
  }
}

public struct WeekoAboutSection: Identifiable {
  public let id: String
  public let title: String
  public let systemImage: String
  public let rows: [WeekoAboutRow]

  public init(
    id: String,
    title: String,
    systemImage: String,
    rows: [WeekoAboutRow]
  ) {
    self.id = id
    self.title = title
    self.systemImage = systemImage
    self.rows = rows
  }
}

public struct WeekoAboutPageConfiguration {
  public let metadata: WeekoApplicationMetadata
  public let identitySectionTitle: String
  public let slogan: String
  public let subtitle: String?
  public let versionTitle: String
  public let buildTitle: String
  public let copyVersionTitle: String
  public let copiedTitle: String
  public let copyFailedMessage: String
  public let openLinkTitle: String
  public let openLinkFailedMessage: String
  public let dismissFeedbackTitle: String
  public let copyright: String?
  public let sections: [WeekoAboutSection]

  public init(
    metadata: WeekoApplicationMetadata,
    identitySectionTitle: String = WeekoLocalization.packageString(
      "weeko_about_identity_section"
    ),
    slogan: String = WeekoLocalization.packageString("weeko_about_slogan"),
    subtitle: String? = WeekoLocalization.packageString("weeko_about_subtitle"),
    versionTitle: String = WeekoLocalization.packageString("weeko_about_version"),
    buildTitle: String = WeekoLocalization.packageString("weeko_about_build"),
    copyVersionTitle: String = WeekoLocalization.packageString("weeko_about_copy_version"),
    copiedTitle: String = WeekoLocalization.packageString("weeko_about_copied"),
    copyFailedMessage: String = WeekoLocalization.packageString("weeko_about_copy_failed"),
    openLinkTitle: String = WeekoLocalization.packageString("weeko_about_open_link"),
    openLinkFailedMessage: String = WeekoLocalization.packageString(
      "weeko_about_open_link_failed"
    ),
    dismissFeedbackTitle: String = WeekoLocalization.packageString("weeko_common_dismiss"),
    copyright: String? = nil,
    sections: [WeekoAboutSection] = []
  ) {
    self.metadata = metadata
    self.identitySectionTitle = identitySectionTitle
    self.slogan = slogan
    self.subtitle = subtitle
    self.versionTitle = versionTitle
    self.buildTitle = buildTitle
    self.copyVersionTitle = copyVersionTitle
    self.copiedTitle = copiedTitle
    self.copyFailedMessage = copyFailedMessage
    self.openLinkTitle = openLinkTitle
    self.openLinkFailedMessage = openLinkFailedMessage
    self.dismissFeedbackTitle = dismissFeedbackTitle
    self.copyright = copyright
    self.sections = sections
  }
}

public enum WeekoAboutPageEvent: Equatable {
  case copiedVersion
  case copyFailed
  case openedURL(URL)
  case failedToOpenURL(URL)
}

public struct WeekoAboutPage: View {
  private struct Feedback: Equatable {
    let message: String
  }

  @Environment(\.weekoMacTheme) private var theme
  @State private var didCopyVersion = false
  @State private var feedback: Feedback?
  @State private var copyResetTask: Task<Void, Never>?

  private let configuration: WeekoAboutPageConfiguration
  private let applicationIcon: NSImage?
  private let openURL: (URL) -> Bool
  private let onEvent: (WeekoAboutPageEvent) -> Void

  public init(
    configuration: WeekoAboutPageConfiguration,
    applicationIcon: NSImage? = nil,
    openURL: @escaping (URL) -> Bool = { NSWorkspace.shared.open($0) },
    onEvent: @escaping (WeekoAboutPageEvent) -> Void = { _ in }
  ) {
    self.configuration = configuration
    self.applicationIcon = applicationIcon
    self.openURL = openURL
    self.onEvent = onEvent
  }

  public var body: some View {
    Group {
      identitySection

      ForEach(configuration.sections) { section in
        configuredSection(section)
      }

      if let feedback {
        Section {
          WeekoSettingsNotice(
            icon: "exclamationmark.triangle.fill",
            tint: .red,
            message: feedback.message
          ) {
            Button {
              self.feedback = nil
            } label: {
              Image(systemName: "xmark")
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(configuration.dismissFeedbackTitle)
          }
          .padding(.vertical, 4)
        }
      }

      if let copyright = configuration.copyright {
        Section {
          Text(copyright)
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .listRowBackground(Color.clear)
        }
      }
    }
    .onDisappear {
      copyResetTask?.cancel()
    }
  }

  private var identitySection: some View {
    WeekoSettingSection(
      configuration.identitySectionTitle,
      icon: "app.badge"
    ) {
      HStack(spacing: 16) {
        Image(nsImage: applicationIcon ?? NSApplication.shared.applicationIconImage)
          .resizable()
          .frame(width: 64, height: 64)
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
          .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 5) {
          Text(configuration.metadata.name)
            .font(.system(size: 20, weight: .bold))

          Text(configuration.slogan)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(theme.accentColor)
            .fixedSize(horizontal: false, vertical: true)

          if let subtitle = configuration.subtitle {
            Text(subtitle)
              .font(.system(size: 12))
              .foregroundStyle(.secondary)
              .fixedSize(horizontal: false, vertical: true)
          }

          HStack(spacing: 7) {
            Text("\(configuration.versionTitle) \(configuration.metadata.version)")
            Text("·").foregroundStyle(.tertiary)
            Text("\(configuration.buildTitle) \(configuration.metadata.build)")
          }
          .font(.system(size: 11, weight: .medium, design: .monospaced))
          .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Button(action: copyVersionInformation) {
          Image(systemName: didCopyVersion ? "checkmark" : "doc.on.doc")
        }
        .buttonStyle(
          WeekoSettingsIconActionButtonStyle(
            tint: didCopyVersion ? .green : theme.accentColor
          )
        )
        .help(didCopyVersion ? configuration.copiedTitle : configuration.copyVersionTitle)
        .accessibilityLabel(
          didCopyVersion ? configuration.copiedTitle : configuration.copyVersionTitle
        )
      }
      .padding(.vertical, 10)
    }
  }

  private func configuredSection(_ section: WeekoAboutSection) -> some View {
    WeekoSettingSection(section.title, icon: section.systemImage) {
      ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
        if index > 0 {
          WeekoSettingDivider()
        }

        if row.url == nil {
          WeekoSettingRowLabel(
            icon: row.icon,
            tint: row.tint,
            title: row.title,
            subtitle: row.subtitle
          )
          .padding(.vertical, WeekoSettingMetrics.rowVerticalPadding)
        } else {
          externalLinkRow(row)
        }
      }
    }
  }

  private func externalLinkRow(_ row: WeekoAboutRow) -> some View {
    WeekoSettingActionRow(
      icon: row.icon,
      tint: row.tint,
      title: row.title,
      subtitle: row.subtitle
    ) {
      Button {
        guard let url = row.url else { return }
        if openURL(url) {
          feedback = nil
          onEvent(.openedURL(url))
        } else {
          feedback = Feedback(message: configuration.openLinkFailedMessage)
          onEvent(.failedToOpenURL(url))
        }
      } label: {
        Image(systemName: "arrow.up.right")
      }
      .buttonStyle(WeekoSettingsIconActionButtonStyle(tint: row.tint))
      .help(configuration.openLinkTitle)
      .accessibilityLabel(row.title)
      .accessibilityHint(configuration.openLinkTitle)
    }
  }

  private func copyVersionInformation() {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    guard
      pasteboard.setString(
        configuration.metadata.diagnosticSummary,
        forType: .string
      )
    else {
      feedback = Feedback(message: configuration.copyFailedMessage)
      onEvent(.copyFailed)
      return
    }

    feedback = nil
    didCopyVersion = true
    onEvent(.copiedVersion)
    copyResetTask?.cancel()
    copyResetTask = Task { @MainActor in
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      guard !Task.isCancelled else { return }
      didCopyVersion = false
    }
  }
}
