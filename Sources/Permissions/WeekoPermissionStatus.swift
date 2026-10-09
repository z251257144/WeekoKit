import Foundation

public enum WeekoPermissionStatus: String, Equatable, Sendable {
  case notDetermined
  case denied
  case authorized
  case restricted
  case unavailable

  public var isAuthorized: Bool {
    self == .authorized
  }

  public var requiresSystemSettings: Bool {
    self == .denied || self == .restricted
  }
}

@MainActor
public protocol WeekoPermissionProviding: AnyObject {
  var status: WeekoPermissionStatus { get }

  func refresh() async -> WeekoPermissionStatus
  func request() async -> WeekoPermissionStatus

  @discardableResult
  func openSystemSettings() -> Bool
}
