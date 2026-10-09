import Foundation

public enum WeekoSubscriptionText {
  public static func localized(_ key: String) -> String {
    WeekoLocalization.packageString(key)
  }

  public static func formatted(_ key: String, _ arguments: CVarArg...) -> String {
    WeekoLocalization.formattedString(
      key,
      arguments: arguments,
      table: "WeekoKit",
      bundle: .module
    )
  }
}
