import AppKit
import UserNotifications

@MainActor
public final class WeekoNotificationPermissionService: WeekoPermissionProviding {
  public private(set) var status: WeekoPermissionStatus = .notDetermined

  public init() {}

  public func refresh() async -> WeekoPermissionStatus {
    let settings = await notificationSettings()
    status = Self.permissionStatus(for: settings.authorizationStatus)
    return status
  }

  public func request() async -> WeekoPermissionStatus {
    let settings = await notificationSettings()
    guard settings.authorizationStatus == .notDetermined else {
      return await refresh()
    }

    do {
      _ = try await UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound]
      )
    } catch {
      status = .denied
      return status
    }

    return await refresh()
  }

  @discardableResult
  public func openSystemSettings() -> Bool {
    guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else {
      return false
    }
    return NSWorkspace.shared.open(url)
  }

  private func notificationSettings() async -> UNNotificationSettings {
    await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        continuation.resume(returning: settings)
      }
    }
  }

  private static func permissionStatus(
    for authorizationStatus: UNAuthorizationStatus
  ) -> WeekoPermissionStatus {
    switch authorizationStatus {
    case .notDetermined:
      return .notDetermined
    case .denied:
      return .denied
    case .authorized, .provisional, .ephemeral:
      return .authorized
    @unknown default:
      return .unavailable
    }
  }
}
