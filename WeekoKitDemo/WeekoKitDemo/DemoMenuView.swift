import AppKit
import SwiftUI
import WeekoKit

@MainActor
struct DemoMenuView: View {
  @Environment(\.weekoMenuDismiss) private var dismissMenu
  @ObservedObject private var screenRecordingCoordinator: WeekoPermissionCoordinator
  @ObservedObject private var microphoneCoordinator: WeekoPermissionCoordinator

  private let theme = WeekoMacTheme(
    accentColor: Color(red: 0.08, green: 0.48, blue: 0.52),
    sidebarWidth: 220
  )

  init() {
    let permissions = DemoPermissionStore.shared
    _screenRecordingCoordinator = ObservedObject(
      wrappedValue: permissions.screenRecordingCoordinator
    )
    _microphoneCoordinator = ObservedObject(
      wrappedValue: permissions.microphoneCoordinator
    )
  }

  var body: some View {
    WeekoMenuPanel {
      WeekoMenuHeader(
        applicationName: "WeekoKit Demo",
        subtitle: DemoText.localized("menu_subtitle")
      ) {
        WeekoMenuStatusButton(title: permissionTitle, tint: permissionTint) {
          showScreenRecordingPermission()
        }
      }
    } content: {
      VStack(alignment: .leading, spacing: 10) {
        WeekoMenuPrimaryButton(
          title: DemoText.localized("menu_open_components"),
          icon: "switch.2",
          shortcut: "⌘1"
        ) {
          openSettings(.components)
        }

        WeekoMenuPrimaryButton(
          title: DemoText.localized("menu_open_tooltip"),
          icon: "text.bubble",
          tint: .blue
        ) {
          openSettings(.tooltip)
        }

        HStack(spacing: 7) {
          WeekoMenuActionButton(
            title: WeekoLocalization.packageString("weeko_settings_menu_application"),
            icon: "macwindow",
            tint: .teal
          ) {
            openSettings(.application)
          }

          WeekoMenuActionButton(
            title: WeekoLocalization.packageString("weeko_settings_menu_permissions"),
            icon: "lock.shield",
            tint: .orange
          ) {
            openSettings(.permission)
          }
        }

        HStack(spacing: 7) {
          WeekoMenuTileButton(
            title: WeekoLocalization.packageString("weeko_settings_menu_license"),
            icon: "sparkles",
            tint: .indigo
          ) {
            openSettings(.commerce)
          }

          WeekoMenuTileButton(
            title: WeekoLocalization.packageString("weeko_settings_menu_about"),
            icon: "info.circle",
            tint: .blue
          ) {
            openSettings(.about)
          }
        }
      }
    } footer: {
      HStack(spacing: 7) {
        WeekoMenuTileButton(
          title: DemoText.localized("menu_settings"),
          icon: "gearshape",
          tint: theme.accentColor
        ) {
          openSettings(.application)
        }

        WeekoMenuTileButton(
          title: DemoText.localized("menu_quit"),
          icon: "power",
          tint: .red,
          role: .destructive
        ) {
          NSApplication.shared.terminate(nil)
        }
      }
    }
    .weekoMacTheme(theme)
  }

  private var permissionTitle: String {
    screenRecordingCoordinator.hasPermission && microphoneCoordinator.hasPermission
      ? DemoText.localized("menu_access_ready")
      : DemoText.localized("menu_needs_access")
  }

  private var permissionTint: Color {
    screenRecordingCoordinator.hasPermission && microphoneCoordinator.hasPermission
      ? .green
      : .orange
  }

  private func openSettings(_ page: DemoPage) {
    dismissMenu()
    Task { @MainActor in
      DemoSettingsWindowController.shared.show(page: page)
    }
  }

  private func showScreenRecordingPermission() {
    dismissMenu()
    Task { @MainActor in
      DemoPermissionWindowController.screenRecording.show()
    }
  }
}
