import SwiftUI

struct WeekoGeneralSettingsSection: View {
  private let launchAtLoginStore: WeekoLaunchAtLoginSettingsStore
  private let dockIconStore: WeekoDockIconSettingsStore
  private let applicationName: String

  init(
    launchAtLoginStore: WeekoLaunchAtLoginSettingsStore,
    dockIconStore: WeekoDockIconSettingsStore,
    applicationName: String = WeekoLocalization.packageString(
      "weeko_application_settings_application"
    )
  ) {
    self.launchAtLoginStore = launchAtLoginStore
    self.dockIconStore = dockIconStore
    self.applicationName = applicationName
  }

  var body: some View {
    WeekoSettingSection(
      WeekoSettingsText.localized("weeko_application_settings_application"),
      icon: "macwindow"
    ) {
      WeekoLaunchAtLoginSettingsRow(
        store: launchAtLoginStore,
        applicationName: applicationName
      )

      WeekoSettingDivider()

      WeekoDockIconSettingsRow(
        store: dockIconStore,
        applicationName: applicationName
      )
    }
  }
}
