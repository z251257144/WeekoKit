import Foundation

public struct WeekoFeedbackURLBuilder: Equatable, Sendable {
  public let baseURL: URL

  public init(baseURL: URL) {
    self.baseURL = baseURL
  }

  public func makeURL(
    metadata: WeekoApplicationMetadata,
    additionalQueryItems: [URLQueryItem] = []
  ) -> URL {
    guard
      var components = URLComponents(
        url: baseURL,
        resolvingAgainstBaseURL: false
      )
    else {
      return baseURL
    }

    var queryItems = components.queryItems ?? []
    queryItems.append(contentsOf: [
      URLQueryItem(name: "app_version", value: metadata.version),
      URLQueryItem(name: "build_number", value: metadata.build),
      URLQueryItem(name: "os_version", value: metadata.operatingSystem),
      URLQueryItem(name: "locale", value: metadata.localeIdentifier),
    ])
    queryItems.append(contentsOf: additionalQueryItems)
    components.queryItems = queryItems
    return components.url ?? baseURL
  }
}
