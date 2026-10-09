import Foundation
import XCTest

@testable import WeekoKit

@MainActor
final class WeekoLanguageSettingsStoreTests: XCTestCase {
  func testRestartUsesInjectedHandlerForPendingLanguageChange() async {
    let suiteName = "WeekoLanguageSettingsStoreTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let restarted = expectation(description: "restart handler is called")
    let store = WeekoLanguageSettingsStore(
      applicationName: "WeekoKit Test",
      languages: [.english, .simplifiedChinese],
      userDefaults: defaults,
      localizationBundle: .main,
      restartHandler: {
        restarted.fulfill()
      }
    )

    store.selectLanguage(id: "zh-Hans")
    XCTAssertTrue(store.languageChangeRequiresRestart)

    store.restartToApplyLanguage()
    await fulfillment(of: [restarted], timeout: 1)

    XCTAssertFalse(store.isRestarting)
  }

  func testLanguageSelectionKeepsThePickerAndRestartNoticeInSync() {
    let suiteName = "WeekoLanguageSettingsStoreTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let store = WeekoLanguageSettingsStore(
      applicationName: "WeekoKit Test",
      languages: [.english, .simplifiedChinese, .traditionalChinese],
      userDefaults: defaults,
      localizationBundle: .main,
      restartHandler: {}
    )

    store.selectLanguage(id: "zh-Hant")

    XCTAssertEqual(store.selectedLanguageID, "zh-Hant")
    XCTAssertEqual(store.selectedLanguage.code, "zh-Hant")
    XCTAssertEqual(store.selectedLanguage.displayName, "繁體中文")
    XCTAssertTrue(store.languageChangeRequiresRestart)
  }
}
