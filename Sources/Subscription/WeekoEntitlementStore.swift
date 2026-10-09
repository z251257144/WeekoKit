import Combine
import Foundation
import StoreKit

@MainActor
public final class WeekoEntitlementStore: ObservableObject {
  private enum VerificationFailure: Error {
    case unverified
    case unexpectedProduct
  }

  @Published public private(set) var plan: WeekoPlan
  @Published public private(set) var products: [WeekoCommerceProduct] = []
  @Published public private(set) var isLoadingProducts = false
  @Published public private(set) var verificationState: WeekoEntitlementVerificationState = .cached
  @Published public private(set) var activity: WeekoCommerceActivity = .idle
  @Published public private(set) var event: WeekoCommerceEvent?
  @Published public private(set) var failure: WeekoCommerceFailure?

  public let configuration: WeekoCommerceConfiguration

  private let userDefaults: UserDefaults
  private var storeProducts: [Product] = []
  private var updatesTask: Task<Void, Never>?
  private var hasStarted = false
  private var productsLoadedAt: Date?
  private var entitlementRefreshGeneration = 0

  public init(
    configuration: WeekoCommerceConfiguration,
    userDefaults: UserDefaults = .standard
  ) {
    self.configuration = configuration
    self.userDefaults = userDefaults
    plan = Self.cachedPlan(configuration: configuration, userDefaults: userDefaults)
  }

  public convenience init(
    annualProductID: String,
    lifetimeProductID: String,
    planCacheKey: String? = nil,
    trustPolicy: WeekoEntitlementTrustPolicy = .verifiedOnly,
    allowsLifetimeUpgrade: Bool = true,
    userDefaults: UserDefaults = .standard
  ) {
    self.init(
      configuration: WeekoCommerceConfiguration(
        annualProductID: annualProductID,
        lifetimeProductID: lifetimeProductID,
        planCacheKey: planCacheKey ?? WeekoCommerceConfiguration.defaultPlanCacheKey,
        trustPolicy: trustPolicy,
        allowsLifetimeUpgrade: allowsLifetimeUpgrade
      ),
      userDefaults: userDefaults
    )
  }

  deinit {
    updatesTask?.cancel()
  }

  public var isPro: Bool {
    guard plan.isPro else { return false }

    switch verificationState {
    case .verified:
      return true
    case .cached, .verifying:
      return configuration.trustPolicy == .useLastKnownWhileRefreshing
    case .failed:
      return false
    }
  }

  public var isBusy: Bool {
    activity != .idle
  }

  public var isRestoring: Bool {
    activity == .restoring
  }

  public func start() {
    guard !hasStarted else { return }
    hasStarted = true

    updatesTask = Task { [weak self] in
      guard let self else { return }
      for await update in Transaction.updates {
        await self.handle(transactionUpdate: update)
      }
    }

    Task { await refreshEntitlements() }
  }

  public func isPurchasing(_ kind: WeekoProductKind) -> Bool {
    activity == .purchasing(kind)
  }

  public func hasProduct(for kind: WeekoProductKind) -> Bool {
    product(for: kind) != nil
  }

  public func canPurchase(_ kind: WeekoProductKind) -> Bool {
    guard !isBusy, hasProduct(for: kind) else { return false }

    switch kind {
    case .annual:
      return plan == .free
    case .lifetime:
      return configuration.allowsLifetimeUpgrade
        ? plan != .proLifetime
        : plan == .free
    }
  }

  public func refreshProducts(force: Bool = false) async {
    guard !isLoadingProducts else { return }
    if !force,
      hasLoadedAllProducts,
      let productsLoadedAt,
      Date().timeIntervalSince(productsLoadedAt) < configuration.productCacheDuration
    {
      return
    }

    failure = nil
    isLoadingProducts = true
    defer { isLoadingProducts = false }

    do {
      let loadedProducts = try await Product.products(for: configuration.productIDs)
      guard !Task.isCancelled else { return }

      storeProducts = loadedProducts
      products = loadedProducts.compactMap { product in
        guard let kind = configuration.productKind(for: product.id) else { return nil }
        return WeekoCommerceProduct(
          id: product.id,
          kind: kind,
          displayName: product.displayName,
          description: product.description,
          displayPrice: product.displayPrice,
          subscriptionPeriod: Self.subscriptionPeriod(for: product)
        )
      }
      .sorted { $0.kind.sortOrder < $1.kind.sortOrder }

      let didLoadAllProducts = hasLoadedAllProducts
      productsLoadedAt = didLoadAllProducts ? Date() : nil
      if !didLoadAllProducts {
        failure = .productsUnavailable
      }
    } catch is CancellationError {
      return
    } catch {
      storeProducts = []
      products = []
      productsLoadedAt = nil
      failure = .productsUnavailable
    }
  }

  public func purchase(_ kind: WeekoProductKind) async {
    guard !isBusy else { return }
    guard let product = product(for: kind), canPurchase(kind) else {
      failure = .productUnavailable(kind)
      return
    }

    clearTransientState()
    activity = .purchasing(kind)
    defer { activity = .idle }

    do {
      switch try await product.purchase() {
      case .success(let verification):
        let transaction = try checkVerified(verification)
        guard transaction.productID == product.id else {
          throw VerificationFailure.unexpectedProduct
        }
        await transaction.finish()

        let confirmedPlan = plan(for: kind)
        guard await refreshEntitlements(confirmedPlan: confirmedPlan) else {
          failure = .verificationFailed
          return
        }
        event = .purchaseSucceeded(kind)
      case .pending:
        event = .purchasePending(kind)
      case .userCancelled:
        event = .purchaseCancelled(kind)
      @unknown default:
        failure = .purchaseFailed(kind)
      }
    } catch is CancellationError {
      return
    } catch is VerificationFailure {
      failure = .verificationFailed
    } catch {
      failure = .purchaseFailed(kind)
    }
  }

  public func restorePurchases() async {
    guard !isBusy else { return }

    clearTransientState()
    activity = .restoring
    defer { activity = .idle }

    do {
      try await AppStore.sync()
      guard await refreshEntitlements() else {
        failure = .verificationFailed
        return
      }
      event = isPro ? .restoreSucceeded(plan) : .restoreFoundNothing
    } catch is CancellationError {
      return
    } catch {
      failure = .restoreFailed
    }
  }

  @discardableResult
  public func refreshEntitlements(confirmedPlan: WeekoPlan? = nil) async -> Bool {
    entitlementRefreshGeneration &+= 1
    let generation = entitlementRefreshGeneration
    verificationState = .verifying

    var nextPlan = confirmedPlan ?? .free
    var foundUnverifiedTransaction = false

    for await result in Transaction.currentEntitlements {
      let transaction: Transaction
      switch result {
      case .verified(let verifiedTransaction):
        transaction = verifiedTransaction
      case .unverified(let unverifiedTransaction, _):
        if configuration.productKind(for: unverifiedTransaction.productID) != nil {
          foundUnverifiedTransaction = true
        }
        continue
      }

      guard transaction.revocationDate == nil,
        let kind = configuration.productKind(for: transaction.productID)
      else {
        continue
      }

      if kind == .lifetime {
        nextPlan = .proLifetime
        break
      }
      if nextPlan != .proLifetime {
        nextPlan = .proAnnual
      }
    }

    guard !Task.isCancelled, entitlementRefreshGeneration == generation else {
      return verificationState == .verified
    }

    if foundUnverifiedTransaction {
      verificationState = .failed
      return false
    }

    apply(plan: nextPlan)
    verificationState = .verified
    return true
  }

  public func clearTransientState() {
    event = nil
    failure = nil
  }

  private var hasLoadedAllProducts: Bool {
    configuration.productIDs.allSatisfy { productID in
      storeProducts.contains { $0.id == productID }
    }
  }

  private func product(for kind: WeekoProductKind) -> Product? {
    let productID = configuration.productID(for: kind)
    return storeProducts.first { $0.id == productID }
  }

  private func plan(for kind: WeekoProductKind) -> WeekoPlan {
    switch kind {
    case .annual: return .proAnnual
    case .lifetime: return .proLifetime
    }
  }

  private func apply(plan nextPlan: WeekoPlan) {
    guard plan != nextPlan else { return }
    plan = nextPlan

    guard let cacheKey = configuration.planCacheKey else { return }
    userDefaults.set(nextPlan.rawValue, forKey: cacheKey)
  }

  private static func cachedPlan(
    configuration: WeekoCommerceConfiguration,
    userDefaults: UserDefaults
  ) -> WeekoPlan {
    guard let cacheKey = configuration.planCacheKey,
      let rawValue = userDefaults.string(forKey: cacheKey),
      let cachedPlan = WeekoPlan(rawValue: rawValue)
    else {
      return .free
    }
    return cachedPlan
  }

  private func handle(
    transactionUpdate update: VerificationResult<Transaction>
  ) async {
    guard let transaction = try? checkVerified(update),
      configuration.productKind(for: transaction.productID) != nil
    else {
      return
    }
    await transaction.finish()
    guard !isBusy else { return }
    await refreshEntitlements()
  }

  private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let value):
      return value
    case .unverified:
      throw VerificationFailure.unverified
    }
  }

  private static func subscriptionPeriod(for product: Product) -> WeekoSubscriptionPeriod? {
    guard let period = product.subscription?.subscriptionPeriod else { return nil }

    let unit: WeekoSubscriptionPeriod.Unit
    switch period.unit {
    case .day: unit = .day
    case .week: unit = .week
    case .month: unit = .month
    case .year: unit = .year
    @unknown default: return nil
    }
    return WeekoSubscriptionPeriod(value: period.value, unit: unit)
  }
}

extension WeekoProductKind {
  fileprivate var sortOrder: Int {
    switch self {
    case .annual: return 0
    case .lifetime: return 1
    }
  }
}
