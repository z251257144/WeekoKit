import Combine
import Foundation

@MainActor
public final class WeekoLanguageSettingsStore: ObservableObject {
  @Published public private(set) var selectedLanguageID: String
  @Published public private(set) var languageChangeRequiresRestart = false
  @Published public private(set) var isRestarting = false
  @Published public private(set) var lastErrorMessage: String?

  public let applicationName: String
  public let localizationStore: WeekoLocalizationStore

  public var languages: [WeekoLocalizationLanguage] {
    localizationStore.supportedLanguages
  }

  public var selectedLanguage: WeekoLocalizationLanguage {
    languages.first(where: { $0.code == selectedLanguageID })
      ?? localizationStore.selectedLanguage
  }

  private let restartHandler: @MainActor () async throws -> Void
  private var cancellables = Set<AnyCancellable>()

  public convenience init(
    applicationName: String? = nil,
    languages: [WeekoLocalizationLanguage] = WeekoLocalizationLanguage.standardOptions,
    userDefaults: UserDefaults = .standard,
    localizationBundle: Bundle = WeekoLocalization.packageBundle,
    restartHandler: @escaping @MainActor () async throws -> Void = {
      try await WeekoApplicationRelauncher.relaunch()
    }
  ) {
    let localizationStore = WeekoLocalizationStore(
      supportedLanguages: languages,
      userDefaults: userDefaults,
      bundle: localizationBundle
    )
    self.init(
      applicationName: applicationName ?? Self.defaultApplicationName(),
      localizationStore: localizationStore,
      restartHandler: restartHandler
    )
  }

  public init(
    applicationName: String,
    localizationStore: WeekoLocalizationStore,
    restartHandler: @escaping @MainActor () async throws -> Void = {
      try await WeekoApplicationRelauncher.relaunch()
    }
  ) {
    self.applicationName = applicationName
    self.localizationStore = localizationStore
    self.restartHandler = restartHandler
    selectedLanguageID = localizationStore.selectedLanguageCode
    languageChangeRequiresRestart = localizationStore.hasPendingLanguageChange

    localizationStore.$selectedLanguageCode
      .sink { [weak self] languageCode in
        self?.synchronizeLocalizationState(selectedLanguageCode: languageCode)
      }
      .store(in: &cancellables)
  }

  public func refresh() {
    localizationStore.refresh()
    synchronizeLocalizationState(selectedLanguageCode: localizationStore.selectedLanguageCode)
  }

  public func selectLanguage(id: String) {
    localizationStore.selectLanguage(code: id)
  }

  public func cancelPendingLanguageChange() {
    localizationStore.cancelPendingLanguageChange()
  }

  public func restartToApplyLanguage() {
    guard languageChangeRequiresRestart, !isRestarting else { return }
    isRestarting = true
    lastErrorMessage = nil

    Task { @MainActor [weak self] in
      guard let self else { return }
      do {
        try await restartHandler()
        isRestarting = false
      } catch {
        isRestarting = false
        lastErrorMessage = error.localizedDescription
      }
    }
  }

  private func synchronizeLocalizationState(selectedLanguageCode: String) {
    selectedLanguageID = selectedLanguageCode
    languageChangeRequiresRestart =
      selectedLanguageCode != localizationStore.effectiveLanguageCode
  }

  private static func defaultApplicationName() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
      ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
      ?? WeekoLocalization.packageString("weeko_application_settings_application")
  }
}
