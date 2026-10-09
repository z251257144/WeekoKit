import Foundation

public struct WeekoLocalizationLanguage: Identifiable, Hashable, Sendable {
  public let code: String
  public let displayName: String

  public init(code: String, displayName: String) {
    self.code = code
    self.displayName = displayName
  }

  public var id: String {
    code
  }

  /// Returns the language name in the current interface language followed by
  /// the language's native name, for example: "英语 - English".
  public func displayName(in locale: Locale) -> String {
    let localizedName = locale.localizedString(forIdentifier: displayIdentifier)
      ?? locale.localizedString(forLanguageCode: displayIdentifier)
      ?? code
    guard localizedName.compare(
      displayName,
      options: [.caseInsensitive, .diacriticInsensitive]
    ) != .orderedSame else {
      return displayName
    }
    return "\(localizedName) - \(displayName)"
  }

  private var displayIdentifier: String {
    code == "pt-BR" ? "pt" : code
  }

  public static let english = WeekoLocalizationLanguage(
    code: "en",
    displayName: "English"
  )

  public static let simplifiedChinese = WeekoLocalizationLanguage(
    code: "zh-Hans",
    displayName: "简体中文"
  )

  public static let traditionalChinese = WeekoLocalizationLanguage(
    code: "zh-Hant",
    displayName: "繁體中文"
  )

  public static let japanese = WeekoLocalizationLanguage(
    code: "ja",
    displayName: "日本語"
  )

  public static let spanish = WeekoLocalizationLanguage(
    code: "es",
    displayName: "Español"
  )

  public static let korean = WeekoLocalizationLanguage(
    code: "ko",
    displayName: "한국어"
  )

  public static let french = WeekoLocalizationLanguage(
    code: "fr",
    displayName: "Français"
  )

  public static let german = WeekoLocalizationLanguage(
    code: "de",
    displayName: "Deutsch"
  )

  public static let portugueseBrazil = WeekoLocalizationLanguage(
    code: "pt-BR",
    displayName: "Português"
  )

  public static let italian = WeekoLocalizationLanguage(
    code: "it",
    displayName: "Italiano"
  )

  public static let dutch = WeekoLocalizationLanguage(
    code: "nl",
    displayName: "Nederlands"
  )

  public static let polish = WeekoLocalizationLanguage(
    code: "pl",
    displayName: "Polski"
  )

  public static let turkish = WeekoLocalizationLanguage(
    code: "tr",
    displayName: "Türkçe"
  )

  public static let russian = WeekoLocalizationLanguage(
    code: "ru",
    displayName: "Русский"
  )

  public static let ukrainian = WeekoLocalizationLanguage(
    code: "uk",
    displayName: "Українська"
  )

  public static let czech = WeekoLocalizationLanguage(
    code: "cs",
    displayName: "Čeština"
  )

  public static let romanian = WeekoLocalizationLanguage(
    code: "ro",
    displayName: "Română"
  )

  public static let swedish = WeekoLocalizationLanguage(
    code: "sv",
    displayName: "Svenska"
  )

  public static let norwegian = WeekoLocalizationLanguage(
    code: "nb",
    displayName: "Norsk bokmål"
  )

  public static let danish = WeekoLocalizationLanguage(
    code: "da",
    displayName: "Dansk"
  )

  public static let finnish = WeekoLocalizationLanguage(
    code: "fi",
    displayName: "Suomi"
  )

  public static let indonesian = WeekoLocalizationLanguage(
    code: "id",
    displayName: "Bahasa Indonesia"
  )

  public static let vietnamese = WeekoLocalizationLanguage(
    code: "vi",
    displayName: "Tiếng Việt"
  )

  public static let thai = WeekoLocalizationLanguage(
    code: "th",
    displayName: "ไทย"
  )

  public static let malay = WeekoLocalizationLanguage(
    code: "ms",
    displayName: "Bahasa Melayu"
  )

  public static let standardOptions: [WeekoLocalizationLanguage] = [
    .english,
    .simplifiedChinese,
    .traditionalChinese,
    .japanese,
    .spanish,
    .korean,
    .french,
    .german,
    .portugueseBrazil,
    .italian,
    .dutch,
    .polish,
    .turkish,
    .russian,
    .ukrainian,
    .czech,
    .romanian,
    .swedish,
    .norwegian,
    .danish,
    .finnish,
    .indonesian,
    .vietnamese,
    .thai,
    .malay,
  ]

  public static func normalizedCode(
    from rawCode: String,
    supportedLanguages: [WeekoLocalizationLanguage] = standardOptions,
    fallbackCode: String = "en"
  ) -> String {
    let normalizedRawCode = rawCode.lowercased().replacingOccurrences(of: "_", with: "-")
    let fallback = supportedLanguages.first(where: {
      $0.code.caseInsensitiveCompare(fallbackCode) == .orderedSame
    })?.code ?? supportedLanguages.first?.code ?? fallbackCode

    if normalizedRawCode.contains("hant")
      || normalizedRawCode.hasPrefix("zh-tw")
      || normalizedRawCode.hasPrefix("zh-hk")
      || normalizedRawCode.hasPrefix("zh-mo") {
      return supportedLanguages.first(where: { $0.code == "zh-Hant" })?.code ?? fallback
    }

    if normalizedRawCode.contains("hans")
      || normalizedRawCode.hasPrefix("zh-cn")
      || normalizedRawCode.hasPrefix("zh-sg")
      || normalizedRawCode == "zh" {
      return supportedLanguages.first(where: { $0.code == "zh-Hans" })?.code ?? fallback
    }

    if let exactMatch = supportedLanguages.first(where: {
      $0.code.caseInsensitiveCompare(normalizedRawCode) == .orderedSame
    }) {
      return exactMatch.code
    }

    let languagePrefix = normalizedRawCode.split(separator: "-").first.map(String.init) ?? fallback

    let aliasedCode: String?
    switch languagePrefix {
    case "pt":
      aliasedCode = "pt-BR"
    case "no":
      aliasedCode = "nb"
    default:
      aliasedCode = nil
    }
    if let aliasedCode,
      let aliasedLanguage = supportedLanguages.first(where: {
        $0.code.caseInsensitiveCompare(aliasedCode) == .orderedSame
      })
    {
      return aliasedLanguage.code
    }

    return supportedLanguages.first(where: {
      $0.code.caseInsensitiveCompare(languagePrefix) == .orderedSame
    })?.code ?? fallback
  }
}

@available(*, deprecated, renamed: "WeekoLocalizationLanguage")
public typealias WeekoApplicationLanguage = WeekoLocalizationLanguage
