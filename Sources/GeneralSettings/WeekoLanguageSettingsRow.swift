import SwiftUI

struct WeekoLanguageSettingsRow: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @ObservedObject private var store: WeekoLanguageSettingsStore

  init(store: WeekoLanguageSettingsStore) {
    _store = ObservedObject(wrappedValue: store)
  }

  var body: some View {
    WeekoSettingRow(
      icon: "character.bubble",
      tint: .teal,
      title: WeekoSettingsText.localized(
        "weeko_application_settings_app_language"
      ),
      subtitle: WeekoSettingsText.formatted(
        "weeko_application_settings_app_language_subtitle",
        arguments: [store.applicationName]
      ),
      trailing: {
      Picker(
        WeekoSettingsText.localized("weeko_application_settings_app_language"),
        selection: languageBinding
      ) {
        ForEach(store.languages) { language in
          Text(language.displayName(in: interfaceLocale)).tag(language.id)
        }
      }
      .labelsHidden()
      }
    )
  }

  private var languageBinding: Binding<String> {
    Binding(
      get: { store.selectedLanguageID },
      set: { languageID in
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.16)) {
          store.selectLanguage(id: languageID)
        }
      }
    )
  }

  private var interfaceLocale: Locale {
    Locale(identifier: store.localizationStore.effectiveLanguageCode)
  }
}
