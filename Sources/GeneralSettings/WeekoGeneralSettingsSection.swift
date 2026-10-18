import SwiftUI

struct WeekoGeneralSettingsSection: View {
  private let launchAtLoginStore: WeekoLaunchAtLoginSettingsStore
  private let dockIconStore: WeekoDockIconSettingsStore
  private let appearanceModeStore: WeekoAppearanceModeStore
  private let applicationName: String

  init(
    launchAtLoginStore: WeekoLaunchAtLoginSettingsStore,
    dockIconStore: WeekoDockIconSettingsStore,
    appearanceModeStore: WeekoAppearanceModeStore,
    applicationName: String = WeekoLocalization.packageString(
      "weeko_application_settings_application"
    )
  ) {
    self.launchAtLoginStore = launchAtLoginStore
    self.dockIconStore = dockIconStore
    self.appearanceModeStore = appearanceModeStore
    self.applicationName = applicationName
  }

  var body: some View {
    WeekoSettingSection(
      WeekoSettingsText.localized("weeko_application_settings_application"),
      icon: "macwindow"
    ) {
      WeekoAppearanceModeSettingsRow(store: appearanceModeStore)
      
      WeekoSettingDivider()
      
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
