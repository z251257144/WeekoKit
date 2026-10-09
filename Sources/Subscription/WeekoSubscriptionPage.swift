import Foundation
import SwiftUI

public struct WeekoSubscriptionPage: View {
  @StateObject private var store: WeekoEntitlementStore
  private let configuration: WeekoSubscriptionViewConfiguration

  public init(
    annualProductID: String,
    lifetimeProductID: String,
    planCacheKey: String? = nil,
    trustPolicy: WeekoEntitlementTrustPolicy = .verifiedOnly,
    allowsLifetimeUpgrade: Bool = true,
    privacyPolicyURL: URL? = URL(string: "https://www.weeko.net/privacy"),
    termsOfUseURL: URL? = URL(string: "https://www.weeko.net/terms"),
    highlights: WeekoSubscriptionHighlightsConfiguration? = nil,
    configuration: WeekoSubscriptionViewConfiguration? = nil
  ) {
    let commerceConfiguration = WeekoCommerceConfiguration(
      annualProductID: annualProductID,
      lifetimeProductID: lifetimeProductID,
      planCacheKey: planCacheKey ?? WeekoCommerceConfiguration.defaultPlanCacheKey,
      trustPolicy: trustPolicy,
      allowsLifetimeUpgrade: allowsLifetimeUpgrade
    )
    _store = StateObject(
      wrappedValue: WeekoEntitlementStore(configuration: commerceConfiguration)
    )
    if let configuration {
      self.configuration = configuration
    } else if let highlights {
      self.configuration = .weekoDefault(
        privacyPolicyURL: privacyPolicyURL,
        termsOfUseURL: termsOfUseURL,
        highlights: highlights
      )
    } else {
      self.configuration = .weekoDefault(
        privacyPolicyURL: privacyPolicyURL,
        termsOfUseURL: termsOfUseURL
      )
    }
  }

  public var body: some View {
    WeekoSettingsFormPage {
      WeekoSubscriptionView(store: store, configuration: configuration)
    }
  }
}
