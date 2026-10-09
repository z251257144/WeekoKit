import AVFoundation
import AppKit

@MainActor
public final class WeekoMicrophonePermissionService: WeekoPermissionProviding {
  public private(set) var status: WeekoPermissionStatus

  public init() {
    status = Self.currentStatus()
  }

  public func refresh() async -> WeekoPermissionStatus {
    status = Self.currentStatus()
    return status
  }

  public func request() async -> WeekoPermissionStatus {
    let current = Self.currentStatus()
    guard current == .notDetermined else {
      status = current
      return status
    }

    _ = await AVCaptureDevice.requestAccess(for: .audio)
    status = Self.currentStatus()
    return status
  }

  @discardableResult
  public func openSystemSettings() -> Bool {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
      )
    else {
      return false
    }
    return NSWorkspace.shared.open(url)
  }

  private static func currentStatus() -> WeekoPermissionStatus {
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    case .authorized:
      return .authorized
    @unknown default:
      return .unavailable
    }
  }
}
