import Foundation
import XCTest

@testable import WeekoKit

@MainActor
final class WeekoLocalizationStoreTests: XCTestCase {
  func testLanguageDisplayNameCombinesLocalizedAndNativeNames() {
    XCTAssertEqual(
      WeekoLocalizationLanguage.english.displayName(in: Locale(identifier: "zh-Hans")),
      "英语 - English"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.simplifiedChinese.displayName(in: Locale(identifier: "en")),
      "Chinese, Simplified - 简体中文"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.english.displayName(in: Locale(identifier: "en")),
      "English"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.simplifiedChinese.displayName(in: Locale(identifier: "zh-Hans")),
      "简体中文"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.traditionalChinese.displayName(in: Locale(identifier: "zh-Hant")),
      "繁體中文"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.portugueseBrazil.displayName(in: Locale(identifier: "zh-Hans")),
      "葡萄牙语 - Português"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.portugueseBrazil.displayName(in: Locale(identifier: "pt-PT")),
      "Português"
    )

    for language in WeekoLocalizationLanguage.standardOptions {
      let locale = Locale(identifier: language.code)
      let localizedName = try! XCTUnwrap(locale.localizedString(forIdentifier: "pt"))
      let expectedName = localizedName.compare(
        "Português",
        options: [.caseInsensitive, .diacriticInsensitive]
      ) == .orderedSame
        ? "Português"
        : "\(localizedName) - Português"

      XCTAssertEqual(
        WeekoLocalizationLanguage.portugueseBrazil.displayName(in: locale),
        expectedName,
        "Portuguese should not use a regional display name in \(language.code)"
      )
    }
  }

  func testNormalizesRegionalChineseCodes() {
    let languages: [WeekoLocalizationLanguage] = [
      .english,
      .simplifiedChinese,
      .traditionalChinese,
    ]

    XCTAssertEqual(
      WeekoLocalizationLanguage.normalizedCode(
        from: "zh-TW",
        supportedLanguages: languages
      ),
      "zh-Hant"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.normalizedCode(
        from: "zh_CN",
        supportedLanguages: languages
      ),
      "zh-Hans"
    )
  }

  func testNormalizesPortugueseAndNorwegianSystemCodes() {
    XCTAssertEqual(
      WeekoLocalizationLanguage.normalizedCode(
        from: "pt_BR",
        supportedLanguages: [.english, .portugueseBrazil]
      ),
      "pt-BR"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.normalizedCode(
        from: "pt",
        supportedLanguages: [.english, .portugueseBrazil]
      ),
      "pt-BR"
    )
    XCTAssertEqual(
      WeekoLocalizationLanguage.normalizedCode(
        from: "no_NO",
        supportedLanguages: [.english, .norwegian]
      ),
      "nb"
    )
  }

  func testLanguageSelectionPersistsAndCanBeCancelled() {
    let suiteName = "WeekoLocalizationStoreTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let store = WeekoLocalizationStore(
      supportedLanguages: [.english, .simplifiedChinese, .traditionalChinese],
      userDefaults: defaults,
      bundle: WeekoLocalization.packageBundle
    )

    store.selectLanguage(code: "zh-Hant")

    XCTAssertEqual(store.selectedLanguageCode, "zh-Hant")
    XCTAssertTrue(store.hasPendingLanguageChange)
    XCTAssertEqual(defaults.array(forKey: "AppleLanguages") as? [String], ["zh-Hant"])

    store.cancelPendingLanguageChange()

    XCTAssertEqual(store.selectedLanguageCode, store.effectiveLanguageCode)
    XCTAssertFalse(store.hasPendingLanguageChange)
    XCTAssertEqual(
      defaults.array(forKey: "AppleLanguages") as? [String],
      [store.effectiveLanguageCode]
    )
  }

  func testSelectedLanguageSurvivesStoreReloadBeforeRelaunch() {
    let suiteName = "WeekoLocalizationStoreTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let store = WeekoLocalizationStore(
      supportedLanguages: [.english, .dutch],
      userDefaults: defaults,
      bundle: WeekoLocalization.packageBundle
    )
    store.selectLanguage(code: "nl")

    let reloadedStore = WeekoLocalizationStore(
      supportedLanguages: [.english, .dutch],
      userDefaults: defaults,
      bundle: WeekoLocalization.packageBundle
    )

    XCTAssertEqual(reloadedStore.selectedLanguageCode, "nl")
  }
}
