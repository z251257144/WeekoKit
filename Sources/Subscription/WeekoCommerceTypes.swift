import Foundation

public enum WeekoPlan: String, CaseIterable, Equatable, Sendable {
  case free
  case proAnnual
  case proLifetime

  public var isPro: Bool {
    self != .free
  }
}

public enum WeekoProductKind: String, CaseIterable, Equatable, Hashable, Sendable {
  case annual
  case lifetime
}

public enum WeekoEntitlementTrustPolicy: Equatable, Sendable {
  case verifiedOnly
  case useLastKnownWhileRefreshing
}

public struct WeekoCommerceConfiguration: Equatable, Sendable {
  public let annualProductID: String
  public let lifetimeProductID: String
  public let planCacheKey: String?
  public let trustPolicy: WeekoEntitlementTrustPolicy
  public let allowsLifetimeUpgrade: Bool
  public let productCacheDuration: TimeInterval

  public init(
    annualProductID: String,
    lifetimeProductID: String,
    planCacheKey: String? = nil,
    trustPolicy: WeekoEntitlementTrustPolicy = .verifiedOnly,
    allowsLifetimeUpgrade: Bool = true,
    productCacheDuration: TimeInterval = 15 * 60
  ) {
    self.annualProductID = annualProductID
    self.lifetimeProductID = lifetimeProductID
    self.planCacheKey = planCacheKey
    self.trustPolicy = trustPolicy
    self.allowsLifetimeUpgrade = allowsLifetimeUpgrade
    self.productCacheDuration = max(0, productCacheDuration)
  }

  public var productIDs: [String] {
    [annualProductID, lifetimeProductID]
  }

  public func productID(for kind: WeekoProductKind) -> String {
    switch kind {
    case .annual: return annualProductID
    case .lifetime: return lifetimeProductID
    }
  }

  public func productKind(for productID: String) -> WeekoProductKind? {
    if productID == annualProductID { return .annual }
    if productID == lifetimeProductID { return .lifetime }
    return nil
  }

  public static var defaultPlanCacheKey: String? {
    Bundle.main.bundleIdentifier.map { "\($0).weekokit.subscription.plan" }
  }
}

public struct WeekoCommerceProduct: Identifiable, Equatable, Sendable {
  public let id: String
  public let kind: WeekoProductKind
  public let displayName: String
  public let description: String
  public let displayPrice: String
  public let subscriptionPeriod: WeekoSubscriptionPeriod?

  public init(
    id: String,
    kind: WeekoProductKind,
    displayName: String,
    description: String,
    displayPrice: String,
    subscriptionPeriod: WeekoSubscriptionPeriod? = nil
  ) {
    self.id = id
    self.kind = kind
    self.displayName = displayName
    self.description = description
    self.displayPrice = displayPrice
    self.subscriptionPeriod = subscriptionPeriod
  }
}

public struct WeekoSubscriptionPeriod: Equatable, Sendable {
  public enum Unit: Equatable, Sendable {
    case day
    case week
    case month
    case year
  }

  public let value: Int
  public let unit: Unit

  public init(value: Int, unit: Unit) {
    self.value = max(1, value)
    self.unit = unit
  }
}

public enum WeekoCommerceActivity: Equatable, Sendable {
  case idle
  case purchasing(WeekoProductKind)
  case restoring
}

public enum WeekoEntitlementVerificationState: Equatable, Sendable {
  case cached
  case verifying
  case verified
  case failed
}

public enum WeekoCommerceEvent: Equatable, Sendable {
  case purchaseSucceeded(WeekoProductKind)
  case purchasePending(WeekoProductKind)
  case purchaseCancelled(WeekoProductKind)
  case restoreSucceeded(WeekoPlan)
  case restoreFoundNothing
}

public enum WeekoCommerceFailure: Error, Equatable, Sendable {
  case productsUnavailable
  case productUnavailable(WeekoProductKind)
  case verificationFailed
  case purchaseFailed(WeekoProductKind)
  case restoreFailed
}
