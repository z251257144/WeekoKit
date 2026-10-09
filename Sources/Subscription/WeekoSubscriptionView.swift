import SwiftUI

public struct WeekoSubscriptionProductPresentation: Identifiable {
  public let kind: WeekoProductKind
  public let icon: String
  public let tint: Color
  public let title: String?
  public let subtitle: String?
  public let purchaseButtonTitle: String
  public let priceSuffix: String?

  public var id: WeekoProductKind { kind }

  public init(
    kind: WeekoProductKind,
    icon: String,
    tint: Color,
    title: String? = nil,
    subtitle: String? = nil,
    purchaseButtonTitle: String,
    priceSuffix: String? = nil
  ) {
    self.kind = kind
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
    self.purchaseButtonTitle = purchaseButtonTitle
    self.priceSuffix = priceSuffix
  }
}

public struct WeekoSubscriptionLegalLink: Identifiable, Equatable, Sendable {
  public let title: String
  public let url: URL

  public var id: URL { url }

  public init(title: String, url: URL) {
    self.title = title
    self.url = url
  }
}

public struct WeekoSubscriptionFeedbackMessages: Equatable, Sendable {
  public let purchaseSucceeded: String
  public let purchasePending: String
  public let restoreSucceeded: String
  public let restoreFoundNothing: String
  public let productsUnavailable: String
  public let productUnavailable: String
  public let verificationFailed: String
  public let purchaseFailed: String
  public let restoreFailed: String

  public init(
    purchaseSucceeded: String = WeekoSubscriptionText.localized(
      "subscription.feedback.purchase_succeeded"
    ),
    purchasePending: String = WeekoSubscriptionText.localized(
      "subscription.feedback.purchase_pending"
    ),
    restoreSucceeded: String = WeekoSubscriptionText.localized(
      "subscription.feedback.restore_succeeded"
    ),
    restoreFoundNothing: String = WeekoSubscriptionText.localized(
      "subscription.feedback.restore_empty"
    ),
    productsUnavailable: String = WeekoSubscriptionText.localized(
      "subscription.feedback.products_unavailable"
    ),
    productUnavailable: String = WeekoSubscriptionText.localized(
      "subscription.feedback.product_unavailable"
    ),
    verificationFailed: String = WeekoSubscriptionText.localized(
      "subscription.feedback.verification_failed"
    ),
    purchaseFailed: String = WeekoSubscriptionText.localized(
      "subscription.feedback.purchase_failed"
    ),
    restoreFailed: String = WeekoSubscriptionText.localized(
      "subscription.feedback.restore_failed"
    )
  ) {
    self.purchaseSucceeded = purchaseSucceeded
    self.purchasePending = purchasePending
    self.restoreSucceeded = restoreSucceeded
    self.restoreFoundNothing = restoreFoundNothing
    self.productsUnavailable = productsUnavailable
    self.productUnavailable = productUnavailable
    self.verificationFailed = verificationFailed
    self.purchaseFailed = purchaseFailed
    self.restoreFailed = restoreFailed
  }
}

public struct WeekoSubscriptionViewConfiguration {
  public let purchaseSectionTitle: String
  public let purchaseSectionIcon: String
  public let products: [WeekoSubscriptionProductPresentation]
  public let renewalNote: String
  public let restoreSectionTitle: String
  public let restoreSectionIcon: String
  public let restoreIcon: String
  public let restoreTint: Color
  public let restoreTitle: String
  public let restoreSubtitle: String
  public let restoreButtonTitle: String
  public let restoringTitle: String
  public let retryTitle: String
  public let loadingPriceTitle: String
  public let unavailablePriceTitle: String
  public let currentPlanTitle: String
  public let dismissFeedbackTitle: String
  public let legalLinks: [WeekoSubscriptionLegalLink]
  public let feedbackMessages: WeekoSubscriptionFeedbackMessages
  public let hidesAnnualSubscriptionForLifetimePlan: Bool
  public let highlights: WeekoSubscriptionHighlightsConfiguration?
  public let currentPlan: WeekoSubscriptionPlanConfiguration?

  public init(
    purchaseSectionTitle: String,
    purchaseSectionIcon: String = "creditcard.fill",
    products: [WeekoSubscriptionProductPresentation],
    renewalNote: String,
    restoreSectionTitle: String,
    restoreSectionIcon: String = "arrow.clockwise",
    restoreIcon: String = "arrow.clockwise.icloud.fill",
    restoreTint: Color,
    restoreTitle: String,
    restoreSubtitle: String,
    restoreButtonTitle: String,
    restoringTitle: String = WeekoSubscriptionText.localized("subscription.restore.progress"),
    retryTitle: String = WeekoSubscriptionText.localized("subscription.retry"),
    loadingPriceTitle: String = WeekoSubscriptionText.localized("subscription.price.loading"),
    unavailablePriceTitle: String = WeekoSubscriptionText.localized(
      "subscription.price.unavailable"
    ),
    currentPlanTitle: String = WeekoSubscriptionText.localized("subscription.current.purchased"),
    dismissFeedbackTitle: String = WeekoSubscriptionText.localized(
      "subscription.feedback.dismiss"
    ),
    legalLinks: [WeekoSubscriptionLegalLink],
    feedbackMessages: WeekoSubscriptionFeedbackMessages = .init(),
    hidesAnnualSubscriptionForLifetimePlan: Bool = true,
    highlights: WeekoSubscriptionHighlightsConfiguration? = .weekoDefault(),
    currentPlan: WeekoSubscriptionPlanConfiguration? = .weekoDefault()
  ) {
    self.purchaseSectionTitle = purchaseSectionTitle
    self.purchaseSectionIcon = purchaseSectionIcon
    self.products = products
    self.renewalNote = renewalNote
    self.restoreSectionTitle = restoreSectionTitle
    self.restoreSectionIcon = restoreSectionIcon
    self.restoreIcon = restoreIcon
    self.restoreTint = restoreTint
    self.restoreTitle = restoreTitle
    self.restoreSubtitle = restoreSubtitle
    self.restoreButtonTitle = restoreButtonTitle
    self.restoringTitle = restoringTitle
    self.retryTitle = retryTitle
    self.loadingPriceTitle = loadingPriceTitle
    self.unavailablePriceTitle = unavailablePriceTitle
    self.currentPlanTitle = currentPlanTitle
    self.dismissFeedbackTitle = dismissFeedbackTitle
    self.legalLinks = legalLinks
    self.feedbackMessages = feedbackMessages
    self.hidesAnnualSubscriptionForLifetimePlan = hidesAnnualSubscriptionForLifetimePlan
    self.highlights = highlights
    self.currentPlan = currentPlan
  }
}

public struct WeekoSubscriptionView<Store: WeekoCommerceStoreProtocol>: View {
  @ObservedObject private var store: Store
  private let configuration: WeekoSubscriptionViewConfiguration

  public init(
    store: Store,
    configuration: WeekoSubscriptionViewConfiguration
  ) {
    self.store = store
    self.configuration = configuration
  }

  public init(store: Store) {
    self.init(store: store, configuration: .weekoDefault())
  }

  @ViewBuilder
  public var body: some View {
    Group {
      if let highlights = configuration.highlights {
        WeekoSubscriptionHighlightsSection(
          configuration: highlights,
          plan: store.plan
        )
      }

      if let currentPlan = configuration.currentPlan {
        WeekoSubscriptionCurrentPlanSection(
          store: store,
          configuration: currentPlan
        )
      }

      WeekoSubscriptionPurchaseSection(store: store, configuration: configuration)
      WeekoSubscriptionRestoreSection(store: store, configuration: configuration)
    }
    .task {
      store.start()
      await store.refreshProducts(force: false)
    }
  }

}

extension WeekoSubscriptionViewConfiguration {
  public static func weekoDefault(
    privacyPolicyURL: URL? = URL(string: "https://www.weeko.net/privacy"),
    termsOfUseURL: URL? = URL(string: "https://www.weeko.net/terms"),
    highlights: WeekoSubscriptionHighlightsConfiguration? = .weekoDefault()
  ) -> WeekoSubscriptionViewConfiguration {
    var legalLinks: [WeekoSubscriptionLegalLink] = []
    if let termsOfUseURL {
      legalLinks.append(
        WeekoSubscriptionLegalLink(
          title: WeekoSubscriptionText.localized("subscription.legal.terms"),
          url: termsOfUseURL
        )
      )
    }
    if let privacyPolicyURL {
      legalLinks.append(
        WeekoSubscriptionLegalLink(
          title: WeekoSubscriptionText.localized("subscription.legal.privacy"),
          url: privacyPolicyURL
        )
      )
    }

    return WeekoSubscriptionViewConfiguration(
      purchaseSectionTitle: WeekoSubscriptionText.localized("subscription.purchase.section"),
      products: [
        WeekoSubscriptionProductPresentation(
          kind: .annual,
          icon: "calendar.badge.checkmark",
          tint: .blue,
          purchaseButtonTitle: WeekoSubscriptionText.localized("subscription.purchase.subscribe")
        ),
        WeekoSubscriptionProductPresentation(
          kind: .lifetime,
          icon: "seal.fill",
          tint: .purple,
          purchaseButtonTitle: WeekoSubscriptionText.localized("subscription.purchase.buy")
        ),
      ],
      renewalNote: WeekoSubscriptionText.localized("subscription.purchase.renewal_note"),
      restoreSectionTitle: WeekoSubscriptionText.localized("subscription.restore.section"),
      restoreTint: .accentColor,
      restoreTitle: WeekoSubscriptionText.localized("subscription.restore.title"),
      restoreSubtitle: WeekoSubscriptionText.localized("subscription.restore.subtitle"),
      restoreButtonTitle: WeekoSubscriptionText.localized("subscription.restore.button"),
      restoringTitle: WeekoSubscriptionText.localized("subscription.restore.progress"),
      retryTitle: WeekoSubscriptionText.localized("subscription.retry"),
      loadingPriceTitle: WeekoSubscriptionText.localized("subscription.price.loading"),
      unavailablePriceTitle: WeekoSubscriptionText.localized("subscription.price.unavailable"),
      currentPlanTitle: WeekoSubscriptionText.localized("subscription.current.purchased"),
      dismissFeedbackTitle: WeekoSubscriptionText.localized("subscription.feedback.dismiss"),
      legalLinks: legalLinks,
      feedbackMessages: WeekoSubscriptionFeedbackMessages(
        purchaseSucceeded: WeekoSubscriptionText.localized(
          "subscription.feedback.purchase_succeeded"
        ),
        purchasePending: WeekoSubscriptionText.localized(
          "subscription.feedback.purchase_pending"
        ),
        restoreSucceeded: WeekoSubscriptionText.localized(
          "subscription.feedback.restore_succeeded"
        ),
        restoreFoundNothing: WeekoSubscriptionText.localized(
          "subscription.feedback.restore_empty"
        ),
        productsUnavailable: WeekoSubscriptionText.localized(
          "subscription.feedback.products_unavailable"
        ),
        productUnavailable: WeekoSubscriptionText.localized(
          "subscription.feedback.product_unavailable"
        ),
        verificationFailed: WeekoSubscriptionText.localized(
          "subscription.feedback.verification_failed"
        ),
        purchaseFailed: WeekoSubscriptionText.localized(
          "subscription.feedback.purchase_failed"
        ),
        restoreFailed: WeekoSubscriptionText.localized(
          "subscription.feedback.restore_failed"
        )
      ),
      highlights: highlights
    )
  }
}
