import SwiftUI

public struct WeekoSubscriptionPurchaseSection<Store: WeekoCommerceStoreProtocol>: View {
  @ObservedObject private var store: Store
  private let configuration: WeekoSubscriptionViewConfiguration

  public init(
    store: Store,
    configuration: WeekoSubscriptionViewConfiguration = .weekoDefault()
  ) {
    _store = ObservedObject(wrappedValue: store)
    self.configuration = configuration
  }

  public var body: some View {
    if showsPurchaseSection {
      WeekoSettingSection(
        configuration.purchaseSectionTitle,
        icon: configuration.purchaseSectionIcon
      ) {
        ForEach(Array(visibleProducts.enumerated()), id: \.element.id) { index, product in
          if index > 0 {
            WeekoSettingDivider()
          }
          WeekoSubscriptionProductRow(
            store: store,
            presentation: product,
            configuration: configuration
          )
        }

        if store.failure == .productsUnavailable {
          WeekoSettingDivider()
          retryRow
        }
      } footer: {
        if visibleProducts.contains(where: { $0.kind == .annual }) {
          Text(configuration.renewalNote)
        }
      }
    }
  }

  private var showsPurchaseSection: Bool {
    !visibleProducts.isEmpty
  }

  private var visibleProducts: [WeekoSubscriptionProductPresentation] {
    guard configuration.hidesAnnualSubscriptionForLifetimePlan,
      store.plan == .proLifetime,
      store.verificationState != .failed
    else {
      return configuration.products
    }
    return configuration.products.filter { $0.kind != .annual }
  }

  private var retryRow: some View {
    WeekoSettingRow(
      icon: "wifi.exclamationmark",
      tint: .orange,
      title: configuration.feedbackMessages.productsUnavailable,
      trailing: {
      if store.isLoadingProducts {
        ProgressView().controlSize(.small)
      } else {
        Button(configuration.retryTitle) {
          Task { await store.refreshProducts(force: true) }
        }
        .buttonStyle(WeekoSettingsActionButtonStyle(tint: .orange))
        .disabled(store.isBusy)
      }
      }
    )
  }
}
