import Combine
import Foundation

@MainActor
public final class WeekoLocalizationStore: ObservableObject {
  @Published public private(set) var selectedLanguageCode: String

  public let supportedLanguages: [WeekoLocalizationLanguage]
  public let effectiveLanguageCode: String

  private let userDefaults: UserDefaults
  private let appleLanguagesKey: String

  public init(
    supportedLanguages: [WeekoLocalizationLanguage] = WeekoLocalizationLanguage.standardOptions,
    userDefaults: UserDefaults = .standard,
    bundle: Bundle = WeekoLocalization.packageBundle,
    appleLanguagesKey: String = "AppleLanguages"
  ) {
    let languages = supportedLanguages.isEmpty ? [.english] : supportedLanguages
    self.supportedLanguages = languages
    self.userDefaults = userDefaults
    self.appleLanguagesKey = appleLanguagesKey

    let effectiveRawCode = bundle.preferredLocalizations.first
      ?? Locale.preferredLanguages.first
      ?? WeekoLocalizationLanguage.english.code
    effectiveLanguageCode = WeekoLocalizationLanguage.normalizedCode(
      from: effectiveRawCode,
      supportedLanguages: languages
    )

    let selectedRawCode = (userDefaults.array(forKey: appleLanguagesKey) as? [String])?.first
      ?? effectiveRawCode
    selectedLanguageCode = WeekoLocalizationLanguage.normalizedCode(
      from: selectedRawCode,
      supportedLanguages: languages,
      fallbackCode: effectiveLanguageCode
    )
  }

  public var hasPendingLanguageChange: Bool {
    selectedLanguageCode != effectiveLanguageCode
  }

  public var selectedLanguage: WeekoLocalizationLanguage {
    supportedLanguages.first(where: { $0.code == selectedLanguageCode })
      ?? supportedLanguages[0]
  }

  public func refresh() {
    let selectedRawCode = (userDefaults.array(forKey: appleLanguagesKey) as? [String])?.first
      ?? effectiveLanguageCode
    selectedLanguageCode = WeekoLocalizationLanguage.normalizedCode(
      from: selectedRawCode,
      supportedLanguages: supportedLanguages,
      fallbackCode: effectiveLanguageCode
    )
  }

  public func selectLanguage(code: String) {
    let normalizedCode = WeekoLocalizationLanguage.normalizedCode(
      from: code,
      supportedLanguages: supportedLanguages,
      fallbackCode: effectiveLanguageCode
    )
    guard selectedLanguageCode != normalizedCode else { return }

    selectedLanguageCode = normalizedCode
    userDefaults.set([normalizedCode], forKey: appleLanguagesKey)
    // The relaunch flow may start the new process immediately. Flush the
    // preference so the new process cannot read the previous language.
    userDefaults.synchronize()
  }

  public func cancelPendingLanguageChange() {
    guard hasPendingLanguageChange else { return }
    selectedLanguageCode = effectiveLanguageCode
    userDefaults.set([effectiveLanguageCode], forKey: appleLanguagesKey)
    userDefaults.synchronize()
  }
}
