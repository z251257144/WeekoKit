import Combine
import Foundation

@MainActor
public final class WeekoSettingsStore: ObservableObject {
  public let launchAtLoginSettingsStore: WeekoLaunchAtLoginSettingsStore
  public let dockIconSettingsStore: WeekoDockIconSettingsStore
  public let languageSettingsStore: WeekoLanguageSettingsStore

  private var cancellables = Set<AnyCancellable>()

  public init(
    applicationName: String? = nil,
    languages: [WeekoLocalizationLanguage] = WeekoLocalizationLanguage.standardOptions,
    userDefaults: UserDefaults = .standard,
    localizationBundle: Bundle = WeekoLocalization.packageBundle,
    dockIconVisibilityDidChange: @escaping @MainActor (Bool) -> Void = { _ in },
    restartHandler: @escaping @MainActor () async throws -> Void = {
      try await WeekoApplicationRelauncher.relaunch()
    }
  ) {
    let launchAtLoginSettingsStore = WeekoLaunchAtLoginSettingsStore()
    let dockIconSettingsStore = WeekoDockIconSettingsStore(
      visibilityDidChange: dockIconVisibilityDidChange
    )
    let languageSettingsStore = WeekoLanguageSettingsStore(
      applicationName: applicationName,
      languages: languages,
      userDefaults: userDefaults,
      localizationBundle: localizationBundle,
      restartHandler: restartHandler
    )

    self.launchAtLoginSettingsStore = launchAtLoginSettingsStore
    self.dockIconSettingsStore = dockIconSettingsStore
    self.languageSettingsStore = languageSettingsStore

    Publishers.Merge3(
      launchAtLoginSettingsStore.objectWillChange,
      dockIconSettingsStore.objectWillChange,
      languageSettingsStore.objectWillChange
    )
    .sink { [weak self] _ in
      self?.objectWillChange.send()
    }
    .store(in: &cancellables)
  }

  public func refresh() {
    launchAtLoginSettingsStore.refresh()
    dockIconSettingsStore.refresh()
    languageSettingsStore.refresh()
  }
}
