import Combine
import Foundation
import ServiceManagement

@MainActor
public final class WeekoLaunchAtLoginSettingsStore: ObservableObject {
  @Published public private(set) var status: WeekoLaunchAtLoginStatus
  @Published public private(set) var lastErrorMessage: String?

  public init() {
    status = Self.currentStatus()
  }

  public var isEnabled: Bool {
    status == .enabled
  }

  public func refresh() {
    status = Self.currentStatus()
  }

  public func setEnabled(_ isEnabled: Bool) {
    lastErrorMessage = nil

    do {
      if isEnabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
    } catch {
      lastErrorMessage = error.localizedDescription
    }

    status = Self.currentStatus()
  }

  private static func currentStatus() -> WeekoLaunchAtLoginStatus {
    switch SMAppService.mainApp.status {
    case .enabled:
      return .enabled
    case .requiresApproval:
      return .requiresApproval
    case .notRegistered, .notFound:
      return .disabled
    @unknown default:
      return .disabled
    }
  }
}
