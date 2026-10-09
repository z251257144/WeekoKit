import Foundation

public enum WeekoPermissionKind: String, CaseIterable, Sendable {
  case screenRecording
  case microphone
  case notifications

  public var title: String {
    WeekoLocalization.packageString("weeko_permissions_\(localizationKeyComponent)_title")
  }

  public var subtitle: String {
    WeekoLocalization.packageString("weeko_permissions_\(localizationKeyComponent)_subtitle")
  }

  public var systemImage: String {
    switch self {
    case .screenRecording: return "record.circle.fill"
    case .microphone: return "mic.fill"
    case .notifications: return "bell.badge.fill"
    }
  }

  func localizedRequestMessage(applicationName: String) -> String {
    localized(
      "request_message",
      arguments: [applicationName]
    )
  }

  func localizedAuthorizedMessage(applicationName: String) -> String {
    localized(
      "authorized_message",
      arguments: [applicationName]
    )
  }

  func localizedInstructions(applicationName: String) -> [String] {
    [
      localized("instruction_1"),
      localized("instruction_2", arguments: [applicationName]),
      localized("instruction_3", arguments: [applicationName]),
    ]
  }

  private func localized(_ suffix: String, arguments: [CVarArg] = []) -> String {
    let key = "weeko_permissions_\(localizationKeyComponent)_\(suffix)"
    guard !arguments.isEmpty else {
      return WeekoLocalization.packageString(key)
    }
    return WeekoLocalization.formattedString(
      key,
      arguments: arguments,
      table: "WeekoKit",
      bundle: .module
    )
  }

  private var localizationKeyComponent: String {
    switch self {
    case .screenRecording: return "screen_recording"
    case .microphone: return "microphone"
    case .notifications: return "notifications"
    }
  }
}
