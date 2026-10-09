import SwiftUI
import WeekoKit

@MainActor
final class DemoAppDelegate: NSObject, NSApplicationDelegate {
  private lazy var menuBarController = WeekoMenuBarController(
    statusItemIcon: .systemSymbol("square.grid.2x2"),
    statusItemToolTip: "WeekoKit Demo",
    statusItemAccessibilityLabel: DemoText.localized("menu_accessibility"),
    onWillPresent: refreshMenuPermissions
  ) {
    DemoMenuView()
  }

  func applicationDidFinishLaunching(_: Notification) {
    DispatchQueue.main.async {
      self.menuBarController.start()
      DemoSettingsWindowController.shared.show()
    }
  }

  func applicationWillTerminate(_: Notification) {
    menuBarController.stop()
  }

  func applicationShouldHandleReopen(
    _: NSApplication,
    hasVisibleWindows _: Bool
  ) -> Bool {
    DemoSettingsWindowController.shared.show()
    return false
  }

  private func refreshMenuPermissions() {
    Task {
      async let screenRecording = DemoPermissionStore.shared.screenRecordingCoordinator.refresh()
      async let microphone = DemoPermissionStore.shared.microphoneCoordinator.refresh()
      _ = await (screenRecording, microphone)
    }
  }
}

@main
struct WeekoKitDemoApp: App {
  @NSApplicationDelegateAdaptor(DemoAppDelegate.self) private var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
    .commands {
      CommandGroup(replacing: .appSettings) {
        Button(DemoText.localized("menu_settings")) {
          DemoSettingsWindowController.shared.show()
        }
        .keyboardShortcut(",", modifiers: .command)
      }
    }
  }
}
