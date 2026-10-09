import AppKit
import Combine

@MainActor
public final class WeekoDockIconSettingsStore: ObservableObject {
  @Published public private(set) var isVisible: Bool
  @Published public private(set) var lastErrorMessage: String?

  private let visibilityDidChange: @MainActor (Bool) -> Void
  private var windowRestoreTask: Task<Void, Never>?

  public init(
    visibilityDidChange: @escaping @MainActor (Bool) -> Void = { _ in }
  ) {
    self.visibilityDidChange = visibilityDidChange
    isVisible = NSApplication.shared.activationPolicy() == .regular
  }

  public func refresh() {
    isVisible = NSApplication.shared.activationPolicy() == .regular
  }

  public func setVisible(_ isVisible: Bool) {
    lastErrorMessage = nil

    let application = NSApplication.shared
    let previousPolicy = application.activationPolicy()
    let policy: NSApplication.ActivationPolicy = isVisible ? .regular : .accessory
    guard previousPolicy != policy else {
      self.isVisible = previousPolicy == .regular
      return
    }

    windowRestoreTask?.cancel()
    let activeWindow = [application.keyWindow, application.mainWindow]
      .compactMap { $0 }
      .first { window in
        window.isVisible && (window.level == .normal || window.level == .floating)
      }

    guard application.setActivationPolicy(policy) else {
      handleUpdateFailure(application: application)
      return
    }

    guard application.activationPolicy() == policy else {
      _ = application.setActivationPolicy(previousPolicy)
      handleUpdateFailure(application: application)
      return
    }

    self.isVisible = isVisible
    restoreVisibleWindow(activeWindow)
    visibilityDidChange(isVisible)
  }

  /// Activation-policy changes settle on the next run loop and can reorder the key window.
  private func restoreVisibleWindow(_ window: NSWindow?) {
    guard let window else { return }

    windowRestoreTask = Task { @MainActor [weak window] in
      await Task.yield()
      guard !Task.isCancelled, let window else { return }

      let application = NSApplication.shared
      let originalLevel = window.level
      window.level = .floating

      if application.isHidden {
        application.unhide(nil)
      }
      NSRunningApplication.current.activate(
        options: [.activateIgnoringOtherApps, .activateAllWindows]
      )
      application.activate(ignoringOtherApps: true)
      window.makeKeyAndOrderFront(nil)
      window.orderFrontRegardless()
      window.level = originalLevel
    }
  }

  private func handleUpdateFailure(application: NSApplication) {
    lastErrorMessage = WeekoLocalization.packageString(
      "weeko_application_settings_dock_icon_update_failed"
    )
    isVisible = application.activationPolicy() == .regular
  }
}
