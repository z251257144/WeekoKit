import SwiftUI

struct WeekoLaunchAtLoginSettingsRow: View {
  @ObservedObject private var store: WeekoLaunchAtLoginSettingsStore
  private let applicationName: String

  init(
    store: WeekoLaunchAtLoginSettingsStore,
    applicationName: String = WeekoLocalization.packageString(
      "weeko_application_settings_application"
    )
  ) {
    _store = ObservedObject(wrappedValue: store)
    self.applicationName = applicationName
  }

  var body: some View {
    WeekoSettingToggleRow(
      isOn: Binding(
        get: { store.isEnabled },
        set: { store.setEnabled($0) }
      ),
      icon: "power",
      tint: .teal,
      title: WeekoSettingsText.localized(
        "weeko_application_settings_open_at_login"
      ),
      subtitle: WeekoSettingsText.formatted(
        "weeko_application_settings_open_at_login_subtitle",
        arguments: [applicationName]
      )
    )
  }
}
