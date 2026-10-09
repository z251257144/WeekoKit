import AppKit
import CoreGraphics
import ScreenCaptureKit

@MainActor
public final class WeekoScreenCapturePermissionService: WeekoPermissionProviding {
  public private(set) var status: WeekoPermissionStatus

  public init() {
    status = CGPreflightScreenCaptureAccess() ? .authorized : .notDetermined
  }

  public func refresh() async -> WeekoPermissionStatus {
    if CGPreflightScreenCaptureAccess() {
      status = .authorized
    } else if status == .authorized {
      status = await verifyUsingScreenCaptureKit() ? .authorized : .denied
    }
    return status
  }

  public func request() async -> WeekoPermissionStatus {
    if CGPreflightScreenCaptureAccess() {
      status = .authorized
      return status
    }

    await Task.yield()
    let nativeResult = CGRequestScreenCaptureAccess()
    if nativeResult || CGPreflightScreenCaptureAccess() {
      status = .authorized
      return status
    }

    status = await verifyUsingScreenCaptureKit() ? .authorized : .denied
    return status
  }

  @discardableResult
  public func openSystemSettings() -> Bool {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
      )
    else {
      return false
    }
    return NSWorkspace.shared.open(url)
  }

  private func verifyUsingScreenCaptureKit() async -> Bool {
    do {
      _ = try await SCShareableContent.excludingDesktopWindows(
        false,
        onScreenWindowsOnly: false
      )
      return true
    } catch {
      return false
    }
  }
}
