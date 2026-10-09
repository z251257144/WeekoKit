import AppKit
import SwiftUI
import WeekoKit

@MainActor
struct ContentView: View {
  @ObservedObject private var navigation: DemoSettingsNavigation
  @ObservedObject private var screenRecordingCoordinator: WeekoPermissionCoordinator
  @ObservedObject private var microphoneCoordinator: WeekoPermissionCoordinator
  @ObservedObject private var notificationCoordinator: WeekoPermissionCoordinator

  private let theme = WeekoMacTheme(
    accentColor: Color(red: 0.08, green: 0.48, blue: 0.52),
    sidebarWidth: 220
  )

  init(
    permissionStore: DemoPermissionStore,
    navigation: DemoSettingsNavigation
  ) {
    _navigation = ObservedObject(wrappedValue: navigation)
    _screenRecordingCoordinator = ObservedObject(
      wrappedValue: permissionStore.screenRecordingCoordinator
    )
    _microphoneCoordinator = ObservedObject(
      wrappedValue: permissionStore.microphoneCoordinator
    )
    _notificationCoordinator = ObservedObject(
      wrappedValue: permissionStore.notificationCoordinator
    )
  }

  var body: some View {
    WeekoSettingsShell(
      applicationName: "WeekoKit Demo",
      groups: navigationGroups,
      selection: $navigation.selection,
      closeTitle: DemoText.localized("close"),
      onClose: closeWindow,
      navigationAccessory: navigationAccessory,
      detail: detailPage
    )
    .weekoMacTheme(theme)
    .frame(minWidth: 900, idealWidth: 940, minHeight: 680, idealHeight: 720)
    .ignoresSafeArea()
    .background(DemoWindowConfigurator())
  }

  private var navigationGroups: [WeekoSettingsNavigationGroup<DemoPage>] {
    [
      WeekoSettingsNavigationGroup(
        id: "features",
        items: [
          .init(
            id: .components,
            title: menuTitle("weeko_settings_menu_components"),
            systemImage: "switch.2",
            tint: theme.accentColor
          ),
          .init(
            id: .tooltip,
            title: DemoText.localized("tooltip_menu"),
            systemImage: "text.bubble",
            tint: .blue
          ),
          .init(
            id: .application,
            title: menuTitle("weeko_settings_menu_application"),
            systemImage: "macwindow",
            tint: .teal
          ),
          .init(
            id: .permission,
            title: menuTitle("weeko_settings_menu_permissions"),
            systemImage: "lock.shield",
            tint: .orange
          ),
        ]
      ),
      WeekoSettingsNavigationGroup(
        id: "footer",
        placement: .bottom,
        items: [
          .init(
            id: .commerce,
            title: menuTitle("weeko_settings_menu_license"),
            systemImage: "sparkles",
            tint: .indigo
          ),
          .init(
            id: .about,
            title: menuTitle("weeko_settings_menu_about"),
            systemImage: "info.circle",
            tint: .secondary
          )
        ]
      ),
    ]
  }

  @ViewBuilder
  private func navigationAccessory(_ page: DemoPage) -> some View {
    if page == .permission,
      !screenRecordingCoordinator.hasPermission
        || !microphoneCoordinator.hasPermission
        || !notificationCoordinator.hasPermission
    {
      Image(systemName: "exclamationmark.circle.fill")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.orange)
        .accessibilityLabel(DemoText.localized("permission_attention"))
    }
  }

  @ViewBuilder
  private func detailPage(_ page: DemoPage) -> some View {
    switch page {
    case .components:
      DemoComponentsPage()
    case .tooltip:
      DemoTooltipPage()
    case .application:
      DemoSettingsPage()
    case .permission:
      DemoPermissionPage(
        screenRecordingCoordinator: screenRecordingCoordinator,
        microphoneCoordinator: microphoneCoordinator,
        notificationCoordinator: notificationCoordinator
      )
    case .commerce:
      DemoCommercePage()
    case .about:
      DemoAboutPage()
    }
  }

  private func closeWindow() {
    DemoSettingsWindowController.shared.hide()
  }

  private func menuTitle(_ key: String) -> String {
    WeekoLocalization.packageString(key)
  }
}

#Preview {
  ContentView(permissionStore: DemoPermissionStore(), navigation: .shared)
    .frame(width: 940, height: 720)
}
