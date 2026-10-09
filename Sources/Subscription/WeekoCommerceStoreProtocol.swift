import Combine

@MainActor
public protocol WeekoCommerceStoreProtocol: ObservableObject {
  var plan: WeekoPlan { get }
  var products: [WeekoCommerceProduct] { get }
  var isLoadingProducts: Bool { get }
  var verificationState: WeekoEntitlementVerificationState { get }
  var activity: WeekoCommerceActivity { get }
  var event: WeekoCommerceEvent? { get }
  var failure: WeekoCommerceFailure? { get }
  var isPro: Bool { get }
  var isBusy: Bool { get }
  var isRestoring: Bool { get }

  func start()
  func isPurchasing(_ kind: WeekoProductKind) -> Bool
  func hasProduct(for kind: WeekoProductKind) -> Bool
  func canPurchase(_ kind: WeekoProductKind) -> Bool
  func refreshProducts(force: Bool) async
  func purchase(_ kind: WeekoProductKind) async
  func restorePurchases() async
  func refreshEntitlements(confirmedPlan: WeekoPlan?) async -> Bool
  func clearTransientState()
}

extension WeekoEntitlementStore: WeekoCommerceStoreProtocol {}
