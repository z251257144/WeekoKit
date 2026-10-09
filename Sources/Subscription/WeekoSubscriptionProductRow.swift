import SwiftUI

public struct WeekoSubscriptionProductRow<Store: WeekoCommerceStoreProtocol>: View {
  @ObservedObject private var store: Store
  private let presentation: WeekoSubscriptionProductPresentation
  private let configuration: WeekoSubscriptionViewConfiguration

  public init(
    store: Store,
    presentation: WeekoSubscriptionProductPresentation,
    configuration: WeekoSubscriptionViewConfiguration = .weekoDefault()
  ) {
    _store = ObservedObject(wrappedValue: store)
    self.presentation = presentation
    self.configuration = configuration
  }

  public var body: some View {
    WeekoSettingRow(
      icon: presentation.icon,
      tint: presentation.tint,
      title: presentation.title ?? product?.displayName ?? fallbackTitle,
      subtitle: presentation.subtitle ?? product?.description ?? fallbackSubtitle,
      titleAccessory: {
        priceLabel
      },
      trailing: {
        productAction
      }
    )
  }

  private var product: WeekoCommerceProduct? {
    store.products.first { $0.kind == presentation.kind }
  }

  @ViewBuilder
  private var priceLabel: some View {
    if let product {
      Text(product.displayPrice + priceSuffix(for: product))
        .font(.system(size: 10, weight: .semibold, design: .rounded))
        .foregroundStyle(presentation.tint)
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(
          Capsule(style: .continuous)
            .fill(presentation.tint.opacity(0.10))
        )
        .fixedSize()
    } else if store.isLoadingProducts {
      HStack(spacing: 5) {
        ProgressView().controlSize(.mini)
        Text(configuration.loadingPriceTitle)
      }
      .font(.system(size: 11, weight: .medium))
      .foregroundStyle(.secondary)
      .fixedSize()
    } else {
      Text(configuration.unavailablePriceTitle)
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
        .fixedSize()
    }
  }

  @ViewBuilder
  private var productAction: some View {
    if isCurrent {
      WeekoSettingsStatusPill(
        title: configuration.currentPlanTitle,
        icon: "checkmark.circle.fill",
        tint: presentation.tint,
        compact: true
      )
    } else if store.isPurchasing(presentation.kind) {
      ProgressView()
        .controlSize(.small)
        .frame(width: WeekoSettingMetrics.actionHeight, height: WeekoSettingMetrics.actionHeight)
        .accessibilityLabel(presentation.purchaseButtonTitle)
    } else {
      Button(presentation.purchaseButtonTitle) {
        Task { await store.purchase(presentation.kind) }
      }
      .buttonStyle(WeekoSettingsActionButtonStyle(tint: presentation.tint))
      .disabled(!store.canPurchase(presentation.kind))
    }
  }

  private var isCurrent: Bool {
    guard store.verificationState == .verified else { return false }
    switch (presentation.kind, store.plan) {
    case (.annual, .proAnnual), (.lifetime, .proLifetime): return true
    default: return false
    }
  }

  private func priceSuffix(for product: WeekoCommerceProduct) -> String {
    if let priceSuffix = presentation.priceSuffix {
      return priceSuffix
    }
    guard let period = product.subscriptionPeriod else { return "" }

    let key: String
    switch (period.unit, period.value == 1) {
    case (.day, true): key = "subscription.period.day"
    case (.day, false): key = "subscription.period.days"
    case (.week, true): key = "subscription.period.week"
    case (.week, false): key = "subscription.period.weeks"
    case (.month, true): key = "subscription.period.month"
    case (.month, false): key = "subscription.period.months"
    case (.year, true): key = "subscription.period.year"
    case (.year, false): key = "subscription.period.years"
    }
    return period.value == 1
      ? WeekoSubscriptionText.localized(key)
      : WeekoSubscriptionText.formatted(key, period.value)
  }

  private var fallbackTitle: String {
    switch presentation.kind {
    case .annual: return WeekoSubscriptionText.localized("subscription.product.annual.title")
    case .lifetime: return WeekoSubscriptionText.localized("subscription.product.lifetime.title")
    }
  }

  private var fallbackSubtitle: String {
    switch presentation.kind {
    case .annual: return WeekoSubscriptionText.localized("subscription.product.annual.subtitle")
    case .lifetime: return WeekoSubscriptionText.localized("subscription.product.lifetime.subtitle")
    }
  }
}
