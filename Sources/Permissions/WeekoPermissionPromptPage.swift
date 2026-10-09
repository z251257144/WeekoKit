import AppKit
import Combine
import SwiftUI

public struct WeekoPermissionPromptConfiguration {
  public let applicationName: String
  public let headerTitle: String?
  public let requestTitle: String
  public let requestMessage: String
  public let authorizedTitle: String
  public let authorizedMessage: String
  public let deniedMessage: String
  public let unavailableMessage: String
  public let instructions: [String]
  public let requestButtonTitle: String
  public let openSettingsButtonTitle: String
  public let doneButtonTitle: String
  public let checkingTitle: String
  public let closeTitle: String
  public let requestSystemImage: String
  public let showsDeniedNotice: Bool
  public let opensSystemSettingsAfterRequestFailure: Bool

  public init(
    applicationName: String,
    headerTitle: String? = nil,
    requestTitle: String,
    requestMessage: String,
    authorizedTitle: String,
    authorizedMessage: String,
    deniedMessage: String,
    unavailableMessage: String,
    instructions: [String],
    requestButtonTitle: String,
    openSettingsButtonTitle: String,
    doneButtonTitle: String,
    checkingTitle: String,
    closeTitle: String,
    requestSystemImage: String,
    showsDeniedNotice: Bool = false,
    opensSystemSettingsAfterRequestFailure: Bool = true
  ) {
    self.applicationName = applicationName
    self.headerTitle = headerTitle
    self.requestTitle = requestTitle
    self.requestMessage = requestMessage
    self.authorizedTitle = authorizedTitle
    self.authorizedMessage = authorizedMessage
    self.deniedMessage = deniedMessage
    self.unavailableMessage = unavailableMessage
    self.instructions = instructions
    self.requestButtonTitle = requestButtonTitle
    self.openSettingsButtonTitle = openSettingsButtonTitle
    self.doneButtonTitle = doneButtonTitle
    self.checkingTitle = checkingTitle
    self.closeTitle = closeTitle
    self.requestSystemImage = requestSystemImage
    self.showsDeniedNotice = showsDeniedNotice
    self.opensSystemSettingsAfterRequestFailure = opensSystemSettingsAfterRequestFailure
  }

  var displaysDeniedNotice: Bool {
    showsDeniedNotice && !opensSystemSettingsAfterRequestFailure
  }
}

extension WeekoPermissionPromptConfiguration {
  public static func defaultApplicationName(bundle: Bundle = .main) -> String {
    bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
      ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
      ?? ProcessInfo.processInfo.processName
  }

  public init(
    applicationName: String? = nil,
    kind: WeekoPermissionKind
  ) {
    self = .weekoDefault(
      applicationName: applicationName ?? Self.defaultApplicationName(),
      kind: kind
    )
  }

  public static func weekoDefault(
    kind: WeekoPermissionKind
  ) -> WeekoPermissionPromptConfiguration {
    WeekoPermissionPromptConfiguration(kind: kind)
  }

  public static func weekoDefault(
    applicationName: String,
    kind: WeekoPermissionKind
  ) -> WeekoPermissionPromptConfiguration {
    WeekoPermissionPromptConfiguration(
      applicationName: applicationName,
      headerTitle: nil,
      requestTitle: WeekoLocalization.formattedString(
        "weeko_permissions_prompt_request_title",
        arguments: [applicationName, kind.title],
        table: "WeekoKit",
        bundle: .module
      ),
      requestMessage: kind.localizedRequestMessage(applicationName: applicationName),
      authorizedTitle: WeekoLocalization.formattedString(
        "weeko_permissions_prompt_authorized_title",
        arguments: [applicationName, kind.title],
        table: "WeekoKit",
        bundle: .module
      ),
      authorizedMessage: kind.localizedAuthorizedMessage(applicationName: applicationName),
      deniedMessage: WeekoLocalization.formattedString(
        "weeko_permissions_prompt_denied_message",
        arguments: [kind.title, applicationName],
        table: "WeekoKit",
        bundle: .module
      ),
      unavailableMessage: WeekoLocalization.formattedString(
        "weeko_permissions_prompt_unavailable_message",
        arguments: [kind.title],
        table: "WeekoKit",
        bundle: .module
      ),
      instructions: kind.localizedInstructions(applicationName: applicationName),
      requestButtonTitle: WeekoLocalization.packageString(
        "weeko_permissions_prompt_continue"
      ),
      openSettingsButtonTitle: WeekoLocalization.packageString(
        "weeko_permissions_prompt_open_settings"
      ),
      doneButtonTitle: WeekoLocalization.packageString("weeko_permissions_prompt_done"),
      checkingTitle: WeekoLocalization.packageString("weeko_permissions_prompt_checking"),
      closeTitle: WeekoLocalization.packageString("weeko_permissions_prompt_close"),
      requestSystemImage: kind.systemImage,
      showsDeniedNotice: false,
      opensSystemSettingsAfterRequestFailure: true
    )
  }
}

enum WeekoPermissionPromptPrimaryAction: Equatable {
  case request
  case openSystemSettings
  case dismiss
}

extension WeekoPermissionPromptConfiguration {
  func primaryAction(for status: WeekoPermissionStatus) -> WeekoPermissionPromptPrimaryAction {
    if status.isAuthorized {
      return .dismiss
    }
    if status == .unavailable {
      return .dismiss
    }
    if status.requiresSystemSettings {
      return .openSystemSettings
    }
    return .request
  }
}

public enum WeekoPermissionPromptEvent: Equatable {
  case granted
  case openedSystemSettings
  case failedToOpenSystemSettings
}

public struct WeekoPermissionPromptPage: View {
  private enum Layout {
    static let contentWidth: CGFloat = 520
    static let primaryActionMinWidth: CGFloat = 248
    static let primaryActionMaxWidth: CGFloat = 360
  }

  @Environment(\.weekoMacTheme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @ObservedObject private var coordinator: WeekoPermissionCoordinator

  private let configuration: WeekoPermissionPromptConfiguration
  private let applicationIcon: NSImage?
  private let onDismiss: () -> Void
  private let onEvent: (WeekoPermissionPromptEvent) -> Void

  public init(
    coordinator: WeekoPermissionCoordinator,
    configuration: WeekoPermissionPromptConfiguration,
    applicationIcon: NSImage? = nil,
    onDismiss: @escaping () -> Void,
    onEvent: @escaping (WeekoPermissionPromptEvent) -> Void = { _ in }
  ) {
    _coordinator = ObservedObject(wrappedValue: coordinator)
    self.configuration = configuration
    self.applicationIcon = applicationIcon
    self.onDismiss = onDismiss
    self.onEvent = onEvent
  }

  public init(
    coordinator: WeekoPermissionCoordinator,
    kind: WeekoPermissionKind,
    applicationName: String? = nil,
    applicationIcon: NSImage? = nil,
    onDismiss: @escaping () -> Void,
    onEvent: @escaping (WeekoPermissionPromptEvent) -> Void = { _ in }
  ) {
    self.init(
      coordinator: coordinator,
      configuration: WeekoPermissionPromptConfiguration(
        applicationName: applicationName,
        kind: kind
      ),
      applicationIcon: applicationIcon,
      onDismiss: onDismiss,
      onEvent: onEvent
    )
  }

  public var body: some View {
    VStack(spacing: 0) {
      header

      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 20) {
          statusIcon

          VStack(spacing: 9) {
            Text(pageTitle)
              .font(.system(size: 18, weight: .bold))

            Text(pageMessage)
              .font(.system(size: 13.5))
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
              .lineSpacing(4)
              .fixedSize(horizontal: false, vertical: true)
          }
          .padding(.horizontal, 48)

          if !coordinator.hasPermission {
            if coordinator.status == .unavailable {
              unavailableNotice
            } else {
              instructions
                .transition(.opacity.combined(with: .move(edge: .bottom)))

              if coordinator.didDenyPermission, configuration.displaysDeniedNotice {
                Label(
                  configuration.deniedMessage,
                  systemImage: "exclamationmark.triangle.fill"
                )
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 440, alignment: .leading)
                .transition(.opacity)
              }
            }
          }
        }
        .padding(.top, coordinator.hasPermission ? 26 : 16)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: coordinator.status)

      footer
    }
    .background {
      ZStack {
        Color(nsColor: .windowBackgroundColor)
        theme.accentColor.opacity(0.035)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: theme.windowCornerRadius, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: theme.windowCornerRadius, style: .continuous)
        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8)
    }
    .task {
      await coordinator.refresh()
    }
    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
      Task { @MainActor in
        await coordinator.refresh()
      }
    }
    .onExitCommand {
      guard !coordinator.isRequesting else { return }
      onDismiss()
    }
  }

  private var header: some View {
    HStack(spacing: 12) {
      Image(nsImage: applicationIcon ?? NSApplication.shared.applicationIconImage)
        .resizable()
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(configuration.applicationName)
          .font(.system(size: 16, weight: .bold))

        if let headerTitle = configuration.headerTitle {
          Text(headerTitle)
            .font(.system(size: 11.5))
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      Button(action: onDismiss) {
        Image(systemName: "xmark")
          .font(.system(size: 12, weight: .bold))
          .frame(width: 30, height: 30)
      }
      .buttonStyle(WeekoCircularIconButtonStyle())
      .disabled(coordinator.isRequesting)
      .help(configuration.closeTitle)
      .accessibilityLabel(configuration.closeTitle)
    }
    .padding(.horizontal, 24)
    .frame(height: 76)
    .overlay(alignment: .bottom) {
      Divider().opacity(0.4)
    }
  }

  private var statusIcon: some View {
    ZStack {
      Circle()
        .fill(statusColor.opacity(0.12))
        .frame(width: 76, height: 76)

      Image(
        systemName: statusSystemImage
      )
      .font(.system(size: 38, weight: .semibold))
      .foregroundStyle(statusColor)
      .symbolRenderingMode(.hierarchical)
      .accessibilityHidden(true)
    }
  }

  @ViewBuilder
  private var instructions: some View {
    if !configuration.instructions.isEmpty {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(Array(configuration.instructions.enumerated()), id: \.offset) { index, text in
          HStack(alignment: .firstTextBaseline, spacing: 11) {
            Text("\(index + 1)")
              .font(.system(size: 11, weight: .bold, design: .rounded))
              .foregroundStyle(theme.accentColor)
              .frame(width: 22, height: 22)
              .background(theme.accentColor.opacity(0.11), in: Circle())

            Text(text)
              .font(.system(size: 13, weight: .medium))
              .foregroundStyle(Color.primary.opacity(0.82))
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(16)
      .frame(maxWidth: Layout.contentWidth, alignment: .leading)
      .background(
        Color.primary.opacity(0.045),
        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
      )
    }
  }

  private var unavailableNotice: some View {
    Label(
      configuration.unavailableMessage,
      systemImage: "xmark.octagon.fill"
    )
    .font(.system(size: 11.5, weight: .medium))
    .foregroundStyle(.red)
    .fixedSize(horizontal: false, vertical: true)
    .frame(maxWidth: 440, alignment: .leading)
    .transition(.opacity)
  }

  private var footer: some View {
    VStack(spacing: 0) {
      Divider().opacity(0.5)

      Button(action: performPrimaryAction) {
        ZStack {
          Text(primaryButtonTitle)
            .opacity(coordinator.isRequesting ? 0 : 1)
            .lineLimit(1)
            .minimumScaleFactor(0.84)

          if coordinator.isRequesting {
            HStack(spacing: 8) {
              ProgressView().controlSize(.small)
              Text(configuration.checkingTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.84)
            }
          }
        }
        .font(.system(size: 14, weight: .semibold))
        .frame(
          minWidth: Layout.primaryActionMinWidth,
          maxWidth: Layout.primaryActionMaxWidth,
          minHeight: 30
        )
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .tint(theme.accentColor)
      .disabled(coordinator.isRequesting)
      .keyboardShortcut(.defaultAction)
      .padding(.vertical, 18)
    }
  }

  private var pageTitle: String {
    coordinator.hasPermission
      ? configuration.authorizedTitle
      : configuration.requestTitle
  }

  private var pageMessage: String {
    coordinator.hasPermission
      ? configuration.authorizedMessage
      : configuration.requestMessage
  }

  private var statusColor: Color {
    if coordinator.hasPermission { return .green }
    if coordinator.status == .unavailable { return .red }
    if coordinator.status.requiresSystemSettings { return .orange }
    return theme.accentColor
  }

  private var statusSystemImage: String {
    if coordinator.hasPermission { return "checkmark" }
    if coordinator.status == .unavailable { return "xmark" }
    return configuration.requestSystemImage
  }

  private var primaryAction: WeekoPermissionPromptPrimaryAction {
    configuration.primaryAction(for: coordinator.status)
  }

  private var primaryButtonTitle: String {
    switch primaryAction {
    case .request: return configuration.requestButtonTitle
    case .openSystemSettings: return configuration.openSettingsButtonTitle
    case .dismiss: return configuration.doneButtonTitle
    }
  }

  private func performPrimaryAction() {
    switch primaryAction {
    case .dismiss:
      onDismiss()
    case .openSystemSettings:
      let opened = coordinator.openSystemSettings()
      onEvent(opened ? .openedSystemSettings : .failedToOpenSystemSettings)
    case .request:
      Task { @MainActor in
        let status = await coordinator.request()
        if status.isAuthorized {
          onEvent(.granted)
        } else if status.requiresSystemSettings,
                  configuration.opensSystemSettingsAfterRequestFailure {
          let opened = coordinator.openSystemSettings()
          onEvent(opened ? .openedSystemSettings : .failedToOpenSystemSettings)
        }
      }
    }
  }
}
