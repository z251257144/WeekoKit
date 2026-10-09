import AppKit

public enum WeekoApplicationRelaunchError: LocalizedError {
  case applicationBundleUnavailable
  case relaunchFailed

  public var errorDescription: String? {
    switch self {
    case .applicationBundleUnavailable:
      return WeekoLocalization.packageString(
        "weeko_application_relaunch_bundle_unavailable"
      )
    case .relaunchFailed:
      return WeekoLocalization.packageString("weeko_application_relaunch_failed")
    }
  }
}

public enum WeekoApplicationRelauncher {
  @MainActor
  public static func relaunch(bundle: Bundle = .main) async throws {
    let applicationURL = bundle.bundleURL
    guard applicationURL.pathExtension.lowercased() == "app" else {
      throw WeekoApplicationRelaunchError.applicationBundleUnavailable
    }

    let configuration = NSWorkspace.OpenConfiguration()
    configuration.activates = true
    configuration.createsNewApplicationInstance = true

    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      NSWorkspace.shared.openApplication(at: applicationURL, configuration: configuration) { application, error in
        if let error {
          continuation.resume(throwing: error)
        } else if application == nil {
          continuation.resume(throwing: WeekoApplicationRelaunchError.relaunchFailed)
        } else {
          continuation.resume(returning: ())
        }
      }
    }

    NSApplication.shared.terminate(nil)
  }
}
