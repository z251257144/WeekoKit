import Foundation
import XCTest

@testable import WeekoKit

final class WeekoLocalizationCompletenessTests: XCTestCase {
  func testLocalizedStringFilesDoNotContainDuplicateKeys() throws {
    for language in WeekoLocalizationLanguage.standardOptions {
      let url = try localizedStringsURL(languageCode: language.code)
      let contents = try String(contentsOf: url, encoding: .utf8)
      let keys = stringKeys(in: contents)
      let duplicateKeys = Dictionary(grouping: keys, by: { $0 })
        .filter { $0.value.count > 1 }
        .map(\.key)
        .sorted()

      XCTAssertTrue(
        duplicateKeys.isEmpty,
        "\(language.code) contains duplicate localization keys: \(duplicateKeys.joined(separator: ", "))"
      )
    }
  }

  func testEverySupportedLanguageContainsTheSameNonemptyStrings() throws {
    let reference = try localizedStrings(languageCode: "en")

    for language in WeekoLocalizationLanguage.standardOptions {
      let strings = try localizedStrings(languageCode: language.code)
      XCTAssertEqual(
        Set(strings.keys),
        Set(reference.keys),
        "\(language.code) must contain exactly the English localization keys"
      )

      for (key, referenceValue) in reference {
        let value = try XCTUnwrap(strings[key], "Missing \(key) in \(language.code)")
        XCTAssertFalse(value.isEmpty, "\(key) is empty in \(language.code)")
        XCTAssertNotEqual(value, key, "\(key) is untranslated in \(language.code)")
        XCTAssertEqual(
          formatTokenCounts(in: value),
          formatTokenCounts(in: referenceValue),
          "\(key) has mismatched format placeholders in \(language.code)"
        )
      }
    }
  }

  func testDefaultPermissionCopyIsAvailableForEveryPermissionKind() {
    for kind in WeekoPermissionKind.allCases {
      let configuration = WeekoPermissionPromptConfiguration.weekoDefault(
        applicationName: "Weeko Test",
        kind: kind
      )

      XCTAssertFalse(kind.title.isEmpty)
      XCTAssertFalse(kind.subtitle.isEmpty)
      XCTAssertNil(configuration.headerTitle)
      XCTAssertFalse(configuration.requestTitle.isEmpty)
      XCTAssertFalse(configuration.authorizedTitle.isEmpty)
      XCTAssertTrue(configuration.requestTitle.contains("Weeko Test"))
      XCTAssertTrue(configuration.requestTitle.contains(kind.title))
      XCTAssertTrue(configuration.authorizedTitle.contains("Weeko Test"))
      XCTAssertTrue(configuration.authorizedTitle.contains(kind.title))
      XCTAssertTrue(configuration.deniedMessage.contains("Weeko Test"))
      XCTAssertTrue(configuration.deniedMessage.contains(kind.title))
      XCTAssertEqual(configuration.instructions.count, 3)
      XCTAssertTrue(configuration.requestMessage.contains("Weeko Test"))
      XCTAssertTrue(configuration.authorizedMessage.contains("Weeko Test"))
      XCTAssertTrue(configuration.instructions[1].contains("Weeko Test"))
      XCTAssertTrue(configuration.instructions[2].contains("Weeko Test"))
      XCTAssertFalse(configuration.showsDeniedNotice)
      XCTAssertTrue(configuration.opensSystemSettingsAfterRequestFailure)
      XCTAssertFalse(configuration.displaysDeniedNotice)
    }
  }

  func testDefaultPermissionConfigurationResolvesAnApplicationName() {
    let configuration = WeekoPermissionPromptConfiguration(kind: .notifications)

    XCTAssertFalse(configuration.applicationName.isEmpty)
  }

  func testDeniedNoticeIsOnlyDisplayedForTheExplicitTwoStepFlow() {
    let twoStepConfiguration = permissionConfiguration(
      showsDeniedNotice: true,
      opensSystemSettingsAfterRequestFailure: false
    )
    let automaticConfiguration = permissionConfiguration(
      showsDeniedNotice: true,
      opensSystemSettingsAfterRequestFailure: true
    )

    XCTAssertTrue(twoStepConfiguration.displaysDeniedNotice)
    XCTAssertFalse(automaticConfiguration.displaysDeniedNotice)
  }

  func testPermissionPrimaryActionFollowsPermissionStatus() {
    let configuration = permissionConfiguration(
      showsDeniedNotice: false,
      opensSystemSettingsAfterRequestFailure: true
    )

    XCTAssertEqual(configuration.primaryAction(for: .notDetermined), .request)
    XCTAssertEqual(configuration.primaryAction(for: .unavailable), .dismiss)
    XCTAssertEqual(configuration.primaryAction(for: .denied), .openSystemSettings)
    XCTAssertEqual(configuration.primaryAction(for: .restricted), .openSystemSettings)
    XCTAssertEqual(configuration.primaryAction(for: .authorized), .dismiss)
  }

  private func localizedStrings(languageCode: String) throws -> [String: String] {
    let url = try localizedStringsURL(languageCode: languageCode)
    let data = try Data(contentsOf: url)
    let propertyList = try PropertyListSerialization.propertyList(from: data, format: nil)
    return try XCTUnwrap(propertyList as? [String: String])
  }

  private func localizedStringsURL(languageCode: String) throws -> URL {
    try XCTUnwrap(
      Bundle.module.url(
        forResource: "WeekoKit",
        withExtension: "strings",
        subdirectory: nil,
        localization: languageCode
      ),
      "Missing WeekoKit.strings for \(languageCode)"
    )
  }

  private func stringKeys(in contents: String) -> [String] {
    let expression = try! NSRegularExpression(
      pattern: #"(?m)^\s*\"((?:\\.|[^\"])*)\"\s*="#
    )
    let range = NSRange(contents.startIndex..., in: contents)
    return expression.matches(in: contents, range: range).compactMap { match in
      guard let keyRange = Range(match.range(at: 1), in: contents) else {
        return nil
      }
      return String(contents[keyRange])
    }
  }

  private func formatTokenCounts(in value: String) -> [String: Int] {
    [
      "%@": value.components(separatedBy: "%@").count - 1,
      "%d": value.components(separatedBy: "%d").count - 1,
    ]
  }

  private func permissionConfiguration(
    showsDeniedNotice: Bool,
    opensSystemSettingsAfterRequestFailure: Bool
  ) -> WeekoPermissionPromptConfiguration {
    WeekoPermissionPromptConfiguration(
      applicationName: "Weeko Test",
      requestTitle: "Request",
      requestMessage: "Request message",
      authorizedTitle: "Authorized",
      authorizedMessage: "Authorized message",
      deniedMessage: "Denied",
      unavailableMessage: "Unavailable",
      instructions: [],
      requestButtonTitle: "Continue",
      openSettingsButtonTitle: "Open Settings",
      doneButtonTitle: "Done",
      checkingTitle: "Checking",
      closeTitle: "Close",
      requestSystemImage: "lock.shield",
      showsDeniedNotice: showsDeniedNotice,
      opensSystemSettingsAfterRequestFailure: opensSystemSettingsAfterRequestFailure
    )
  }
}
