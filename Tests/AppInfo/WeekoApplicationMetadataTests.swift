import Foundation
import XCTest

@testable import WeekoKit

final class WeekoApplicationMetadataTests: XCTestCase {
  func testDiagnosticSummaryUsesStableFieldOrder() {
    let metadata = WeekoApplicationMetadata(
      name: "Weeko Test",
      version: "2.3",
      build: "45",
      operatingSystem: "15.5",
      localeIdentifier: "zh-Hans",
      additionalDiagnosticLines: ["Model: Test Mac"]
    )

    XCTAssertEqual(
      metadata.diagnosticSummary,
      """
      Weeko Test
      \(WeekoLocalization.packageString("weeko_diagnostics_version")): 2.3
      \(WeekoLocalization.packageString("weeko_diagnostics_build")): 45
      \(WeekoLocalization.packageString("weeko_diagnostics_macos")): 15.5
      \(WeekoLocalization.packageString("weeko_diagnostics_locale")): zh-Hans
      Model: Test Mac
      """
    )
    XCTAssertEqual(metadata.displayVersion, "2.3 (45)")
  }

  func testFeedbackURLPreservesExistingQueryAndAddsDiagnostics() throws {
    let metadata = WeekoApplicationMetadata(
      name: "Weeko Test",
      version: "1.4",
      build: "19",
      operatingSystem: "macOS Test",
      localeIdentifier: "en"
    )
    let builder = WeekoFeedbackURLBuilder(
      baseURL: try XCTUnwrap(URL(string: "https://example.com/feedback?source=app"))
    )

    let url = builder.makeURL(
      metadata: metadata,
      additionalQueryItems: [URLQueryItem(name: "channel", value: "settings")]
    )
    let components = try XCTUnwrap(
      URLComponents(url: url, resolvingAgainstBaseURL: false)
    )
    let values = Dictionary(
      uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) }
    )

    XCTAssertEqual(values["source"], "app")
    XCTAssertEqual(values["app_version"], "1.4")
    XCTAssertEqual(values["build_number"], "19")
    XCTAssertEqual(values["os_version"], "macOS Test")
    XCTAssertEqual(values["locale"], "en")
    XCTAssertEqual(values["channel"], "settings")
  }
}
