import SwiftUI

struct WeekoLanguageSettingsSection: View {
  @Environment(\.weekoMacTheme) private var theme
  @ObservedObject private var store: WeekoLanguageSettingsStore

  init(store: WeekoLanguageSettingsStore) {
    _store = ObservedObject(wrappedValue: store)
  }

  var body: some View {
    WeekoSettingSection(
      WeekoSettingsText.localized("weeko_application_settings_language"),
      icon: "character.bubble"
    ) {
      WeekoLanguageSettingsRow(store: store)

      if store.languageChangeRequiresRestart {
        WeekoSettingDivider()

        languageRestartNotice
          .padding(.vertical, 10)
      }
    }
  }

  private var languageRestartNotice: some View {
    WeekoSettingsNotice(
      icon: "arrow.clockwise.circle.fill",
      tint: .orange,
      message: WeekoSettingsText.restartMessage(
        applicationName: store.applicationName,
        languageName: store.selectedLanguage.displayName(in: interfaceLocale)
      )
    ) {
      Button {
        store.restartToApplyLanguage()
      } label: {
        if store.isRestarting {
          ProgressView()
            .controlSize(.small)
            .frame(width: 52)
        } else {
          Label(
            WeekoSettingsText.localized(
              "weeko_application_settings_restart_now"
            ),
            systemImage: "arrow.clockwise"
          )
        }
      }
      .buttonStyle(WeekoSettingsActionButtonStyle(tint: theme.accentColor))
      .disabled(store.isRestarting)
    }
  }

  private var interfaceLocale: Locale {
    Locale(identifier: store.localizationStore.effectiveLanguageCode)
  }
}
