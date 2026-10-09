import SwiftUI

struct WeekoDockIconSettingsRow: View {
  @ObservedObject private var store: WeekoDockIconSettingsStore
  private let applicationName: String

  init(
    store: WeekoDockIconSettingsStore,
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
        get: { store.isVisible },
        set: { store.setVisible($0) }
      ),
      icon: "dock.rectangle",
      tint: .blue,
      title: WeekoSettingsText.localized(
        "weeko_application_settings_show_dock_icon"
      ),
      subtitle: WeekoSettingsText.formatted(
        "weeko_application_settings_show_dock_icon_subtitle",
        arguments: [applicationName]
      )
    )
  }
}
