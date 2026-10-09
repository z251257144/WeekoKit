public extension WeekoSettingsStore {
  var launchAtLoginStatus: WeekoLaunchAtLoginStatus {
    launchAtLoginSettingsStore.status
  }

  var isLaunchAtLoginEnabled: Bool {
    launchAtLoginSettingsStore.isEnabled
  }

  var isDockIconVisible: Bool {
    dockIconSettingsStore.isVisible
  }

  var applicationName: String {
    languageSettingsStore.applicationName
  }

  var localizationStore: WeekoLocalizationStore {
    languageSettingsStore.localizationStore
  }

  var selectedLanguageID: String {
    languageSettingsStore.selectedLanguageID
  }

  var languageChangeRequiresRestart: Bool {
    languageSettingsStore.languageChangeRequiresRestart
  }

  var isRestarting: Bool {
    languageSettingsStore.isRestarting
  }

  var languages: [WeekoLocalizationLanguage] {
    languageSettingsStore.languages
  }

  var selectedLanguage: WeekoLocalizationLanguage {
    languageSettingsStore.selectedLanguage
  }

  var lastErrorMessage: String? {
    launchAtLoginSettingsStore.lastErrorMessage
      ?? dockIconSettingsStore.lastErrorMessage
      ?? languageSettingsStore.lastErrorMessage
  }

  func setLaunchAtLoginEnabled(_ isEnabled: Bool) {
    launchAtLoginSettingsStore.setEnabled(isEnabled)
  }

  func setDockIconVisible(_ isVisible: Bool) {
    dockIconSettingsStore.setVisible(isVisible)
  }

  func selectLanguage(id: String) {
    languageSettingsStore.selectLanguage(id: id)
  }

  func cancelPendingLanguageChange() {
    languageSettingsStore.cancelPendingLanguageChange()
  }

  func restartToApplyLanguage() {
    languageSettingsStore.restartToApplyLanguage()
  }
}
