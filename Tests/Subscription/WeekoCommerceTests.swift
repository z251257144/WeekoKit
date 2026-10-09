import Foundation
import XCTest

@testable import WeekoKit

@MainActor
final class WeekoCommerceTests: XCTestCase {
  func testConfigurationMapsOnlyKnownProductIdentifiers() {
    let configuration = makeConfiguration(cacheKey: nil)

    XCTAssertEqual(configuration.productKind(for: "example.yearly"), .annual)
    XCTAssertEqual(configuration.productKind(for: "example.lifetime"), .lifetime)
    XCTAssertNil(configuration.productKind(for: "example.unknown"))
    XCTAssertEqual(configuration.productID(for: .annual), "example.yearly")
    XCTAssertEqual(configuration.productID(for: .lifetime), "example.lifetime")
  }

  func testVerifiedOnlyPolicyDoesNotUnlockCachedPlan() {
    let suiteName = "WeekoCommerceTests.VerifiedOnly.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }
    defaults.set(WeekoPlan.proAnnual.rawValue, forKey: "cached-plan")

    let store = WeekoEntitlementStore(
      configuration: makeConfiguration(
        cacheKey: "cached-plan",
        trustPolicy: .verifiedOnly
      ),
      userDefaults: defaults
    )

    XCTAssertEqual(store.plan, .proAnnual)
    XCTAssertEqual(store.verificationState, .cached)
    XCTAssertFalse(store.isPro)
  }

  func testLastKnownPolicyCanUnlockDuringInitialRefresh() {
    let suiteName = "WeekoCommerceTests.LastKnown.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }
    defaults.set(WeekoPlan.proLifetime.rawValue, forKey: "cached-plan")

    let store = WeekoEntitlementStore(
      configuration: makeConfiguration(
        cacheKey: "cached-plan",
        trustPolicy: .useLastKnownWhileRefreshing
      ),
      userDefaults: defaults
    )

    XCTAssertEqual(store.plan, .proLifetime)
    XCTAssertTrue(store.isPro)
  }

  func testNegativeProductCacheDurationIsClamped() {
    let configuration = WeekoCommerceConfiguration(
      annualProductID: "example.yearly",
      lifetimeProductID: "example.lifetime",
      productCacheDuration: -10
    )

    XCTAssertEqual(configuration.productCacheDuration, 0)
  }

  func testConvenienceStoreInitializerOnlyNeedsProductIdentifiers() {
    let store = WeekoEntitlementStore(
      annualProductID: "example.yearly",
      lifetimeProductID: "example.lifetime",
      planCacheKey: "example.plan"
    )

    XCTAssertEqual(store.configuration.annualProductID, "example.yearly")
    XCTAssertEqual(store.configuration.lifetimeProductID, "example.lifetime")
    XCTAssertEqual(store.configuration.planCacheKey, "example.plan")
  }

  func testSubscriptionPeriodClampsInvalidValues() {
    let period = WeekoSubscriptionPeriod(value: 0, unit: .month)

    XCTAssertEqual(period.value, 1)
    XCTAssertEqual(period.unit, .month)
  }

  func testDefaultSubscriptionViewConfigurationProvidesBothProducts() {
    let configuration = WeekoSubscriptionViewConfiguration.weekoDefault(
      privacyPolicyURL: nil,
      termsOfUseURL: nil
    )

    XCTAssertEqual(configuration.products.map(\.kind), [.annual, .lifetime])
    XCTAssertTrue(configuration.legalLinks.isEmpty)
    XCTAssertNotNil(configuration.highlights)
  }

  func testDefaultSubscriptionViewConfigurationUsesInjectedHighlights() {
    let highlights = WeekoSubscriptionHighlightsConfiguration(
      title: "Product-specific benefits",
      subtitle: "Configured by the app.",
      historyBadgeTitle: "Flexible plans",
      localBadgeTitle: "Secure payment",
      features: []
    )
    let configuration = WeekoSubscriptionViewConfiguration.weekoDefault(
      privacyPolicyURL: nil,
      termsOfUseURL: nil,
      highlights: highlights
    )

    XCTAssertEqual(configuration.highlights?.title, "Product-specific benefits")
    XCTAssertEqual(configuration.highlights?.features.count, 0)
  }

  private func makeConfiguration(
    cacheKey: String?,
    trustPolicy: WeekoEntitlementTrustPolicy = .verifiedOnly
  ) -> WeekoCommerceConfiguration {
    WeekoCommerceConfiguration(
      annualProductID: "example.yearly",
      lifetimeProductID: "example.lifetime",
      planCacheKey: cacheKey,
      trustPolicy: trustPolicy
    )
  }
}
