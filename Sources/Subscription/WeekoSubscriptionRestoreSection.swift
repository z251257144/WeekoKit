import SwiftUI

public struct WeekoSubscriptionRestoreSection<Store: WeekoCommerceStoreProtocol>: View {
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
    WeekoSettingSection(
      configuration.restoreSectionTitle,
      icon: configuration.restoreSectionIcon
    ) {
      WeekoSettingRow(
        icon: configuration.restoreIcon,
        tint: configuration.restoreTint,
        title: configuration.restoreTitle,
        subtitle: configuration.restoreSubtitle,
        trailing: {
        restoreAction
        }
      )

      if let feedback = feedbackPresentation {
        WeekoSettingDivider()
        WeekoSettingsNotice(
          icon: feedback.icon,
          tint: feedback.tint,
          message: feedback.message
        ) {
          Button(action: store.clearTransientState) {
            Image(systemName: "xmark")
              .frame(width: 24, height: 24)
          }
          .buttonStyle(.borderless)
          .accessibilityLabel(configuration.dismissFeedbackTitle)
        }
        .padding(.vertical, 10)
      }
    } footer: {
      legalLinksFooter
    }
  }

  @ViewBuilder
  private var restoreAction: some View {
    if store.isRestoring {
      HStack(spacing: 7) {
        ProgressView().controlSize(.small)
        Text(configuration.restoringTitle)
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(.secondary)
      }
      .fixedSize()
    } else {
      Button {
        Task { await store.restorePurchases() }
      } label: {
        Label(configuration.restoreButtonTitle, systemImage: "arrow.clockwise")
      }
      .buttonStyle(WeekoSettingsActionButtonStyle(tint: configuration.restoreTint))
      .disabled(store.isBusy)
    }
  }

  @ViewBuilder
  private var legalLinksFooter: some View {
    if !configuration.legalLinks.isEmpty {
      HStack(spacing: 8) {
        Spacer(minLength: 0)
        ForEach(Array(configuration.legalLinks.enumerated()), id: \.element.id) { index, link in
          if index > 0 {
            Text("·")
              .foregroundStyle(.tertiary)
          }
          Link(link.title, destination: link.url)
        }
        Spacer(minLength: 0)
      }
      .font(.system(size: 11))
      .foregroundStyle(.secondary)
    }
  }

  private var feedbackPresentation: FeedbackPresentation? {
    if let failure = store.failure {
      let message: String
      switch failure {
      case .productsUnavailable:
        return nil
      case .productUnavailable:
        message = configuration.feedbackMessages.productUnavailable
      case .verificationFailed:
        message = configuration.feedbackMessages.verificationFailed
      case .purchaseFailed:
        message = configuration.feedbackMessages.purchaseFailed
      case .restoreFailed:
        message = configuration.feedbackMessages.restoreFailed
      }
      return FeedbackPresentation(icon: "exclamationmark.circle.fill", tint: .red, message: message)
    }

    guard let event = store.event else { return nil }
    switch event {
    case .purchaseSucceeded:
      return FeedbackPresentation(
        icon: "checkmark.circle.fill",
        tint: .green,
        message: configuration.feedbackMessages.purchaseSucceeded
      )
    case .purchasePending:
      return FeedbackPresentation(
        icon: "clock.fill",
        tint: .orange,
        message: configuration.feedbackMessages.purchasePending
      )
    case .purchaseCancelled:
      return nil
    case .restoreSucceeded:
      return FeedbackPresentation(
        icon: "checkmark.circle.fill",
        tint: .green,
        message: configuration.feedbackMessages.restoreSucceeded
      )
    case .restoreFoundNothing:
      return FeedbackPresentation(
        icon: "info.circle.fill",
        tint: .blue,
        message: configuration.feedbackMessages.restoreFoundNothing
      )
    }
  }
}

private struct FeedbackPresentation {
  let icon: String
  let tint: Color
  let message: String
}
