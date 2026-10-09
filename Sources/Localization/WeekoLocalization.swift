import Foundation

public enum WeekoLocalization {
  /// The localization bundle shipped with the WeekoKit package.
  ///
  /// This is public so library clients can use the package resources in
  /// default arguments without reaching into Swift Package Manager's
  /// internal `Bundle.module` accessor.
  public static let packageBundle: Bundle = .module

  public static func packageString(
    _ key: String,
    fallbackLanguageCode: String = "en"
  ) -> String {
    string(
      key,
      table: "WeekoKit",
      bundle: .module,
      fallbackLanguageCode: fallbackLanguageCode
    )
  }

  public static func string(
    _ key: String,
    table: String? = nil,
    bundle: Bundle = .main,
    fallbackLanguageCode: String = "en"
  ) -> String {
    let localized = bundle.localizedString(forKey: key, value: key, table: table)
    guard localized == key,
      let path = bundle.path(forResource: fallbackLanguageCode, ofType: "lproj"),
      let fallbackBundle = Bundle(path: path)
    else {
      return localized
    }

    return fallbackBundle.localizedString(forKey: key, value: key, table: table)
  }

  public static func formattedString(
    _ key: String,
    arguments: [CVarArg],
    table: String? = nil,
    bundle: Bundle = .main,
    fallbackLanguageCode: String = "en",
    locale: Locale = .current
  ) -> String {
    String(
      format: string(
        key,
        table: table,
        bundle: bundle,
        fallbackLanguageCode: fallbackLanguageCode
      ),
      locale: locale,
      arguments: arguments
    )
  }
}

public extension String {
  func weekoLocalized(
    table: String? = nil,
    bundle: Bundle = .main,
    fallbackLanguageCode: String = "en"
  ) -> String {
    WeekoLocalization.string(
      self,
      table: table,
      bundle: bundle,
      fallbackLanguageCode: fallbackLanguageCode
    )
  }

  func weekoLocalizedFormat(
    _ arguments: CVarArg...,
    table: String? = nil,
    bundle: Bundle = .main,
    fallbackLanguageCode: String = "en",
    locale: Locale = .current
  ) -> String {
    WeekoLocalization.formattedString(
      self,
      arguments: arguments,
      table: table,
      bundle: bundle,
      fallbackLanguageCode: fallbackLanguageCode,
      locale: locale
    )
  }
}
