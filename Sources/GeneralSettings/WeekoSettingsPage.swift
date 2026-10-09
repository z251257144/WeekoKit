import SwiftUI

public struct WeekoSettingsPage: View {
  @ObservedObject private var store: WeekoSettingsStore

  public init(store: WeekoSettingsStore) {
    _store = ObservedObject(wrappedValue: store)
  }

  public var body: some View {
    WeekoSettingsFormPage {
      WeekoGeneralSettingsSection(
        launchAtLoginStore: store.launchAtLoginSettingsStore,
        dockIconStore: store.dockIconSettingsStore,
        applicationName: store.applicationName
      )
      WeekoLanguageSettingsSection(store: store.languageSettingsStore)

      if store.launchAtLoginStatus == .requiresApproval {
        WeekoSettingsNotice(
          icon: "exclamationmark.triangle.fill",
          tint: .orange,
          message: WeekoSettingsText.formatted(
            "weeko_application_settings_login_approval",
            arguments: [store.applicationName]
          )
        )
      }

      if let lastErrorMessage = store.lastErrorMessage {
        WeekoSettingsNotice(
          icon: "exclamationmark.triangle.fill",
          tint: .red,
          message: lastErrorMessage
        )
      }
    }
    .onAppear {
      store.refresh()
    }
  }
}

enum WeekoSettingsText {
  static func localized(_ key: String) -> String {
    WeekoLocalization.string(key, table: "WeekoKit", bundle: .module)
  }

  static func formatted(_ key: String, arguments: [CVarArg]) -> String {
    WeekoLocalization.formattedString(
      key,
      arguments: arguments,
      table: "WeekoKit",
      bundle: .module
    )
  }

  static func restartMessage(applicationName: String, languageName: String) -> String {
    WeekoLocalization.formattedString(
      "weeko_application_settings_language_restart_pending",
      arguments: [applicationName, languageName],
      table: "WeekoKit",
      bundle: .module
    )
  }
}
