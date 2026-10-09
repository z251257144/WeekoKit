import Foundation

public struct WeekoApplicationMetadata: Equatable, Sendable {
  public let name: String
  public let version: String
  public let build: String
  public let operatingSystem: String
  public let localeIdentifier: String
  public let additionalDiagnosticLines: [String]

  public init(
    name: String,
    version: String,
    build: String,
    operatingSystem: String = ProcessInfo.processInfo.operatingSystemVersionString,
    localeIdentifier: String = Locale.current.identifier,
    additionalDiagnosticLines: [String] = []
  ) {
    self.name = name
    self.version = version
    self.build = build
    self.operatingSystem = operatingSystem
    self.localeIdentifier = localeIdentifier
    self.additionalDiagnosticLines = additionalDiagnosticLines
  }

  public init(
    bundle: Bundle = .main,
    fallbackName: String,
    fallbackVersion: String = "1.0",
    fallbackBuild: String = "1",
    additionalDiagnosticLines: [String] = []
  ) {
    let name =
      bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
      ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
      ?? fallbackName
    let version =
      bundle.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
      ) as? String ?? fallbackVersion
    let build =
      bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
      ?? fallbackBuild
    let locale = bundle.preferredLocalizations.first ?? Locale.current.identifier

    self.init(
      name: name,
      version: version,
      build: build,
      localeIdentifier: locale,
      additionalDiagnosticLines: additionalDiagnosticLines
    )
  }

  public var displayVersion: String {
    "\(version) (\(build))"
  }

  public var diagnosticSummary: String {
    var lines = [
      name,
      "\(WeekoLocalization.packageString("weeko_diagnostics_version")): \(version)",
      "\(WeekoLocalization.packageString("weeko_diagnostics_build")): \(build)",
      "\(WeekoLocalization.packageString("weeko_diagnostics_macos")): \(operatingSystem)",
      "\(WeekoLocalization.packageString("weeko_diagnostics_locale")): \(localeIdentifier)",
    ]
    lines.append(contentsOf: additionalDiagnosticLines)
    return lines.joined(separator: "\n")
  }
}
