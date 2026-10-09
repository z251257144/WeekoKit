import SwiftUI

public struct WeekoSubscriptionCurrentPlanSection<Store: WeekoCommerceStoreProtocol>: View {
  @ObservedObject private var store: Store
  private let configuration: WeekoSubscriptionPlanConfiguration

  public init(
    store: Store,
    configuration: WeekoSubscriptionPlanConfiguration = .weekoDefault()
  ) {
    _store = ObservedObject(wrappedValue: store)
    self.configuration = configuration
  }

  public var body: some View {
    WeekoSettingSection(configuration.sectionTitle, icon: configuration.sectionIcon) {
      WeekoSettingRow(
        icon: planIcon,
        tint: planTint,
        title: configuration.displayTitle ?? plan.title,
        subtitle: planSubtitle,
        trailing: {
        HStack(spacing: 8) {
          if isChecking {
            ProgressView().controlSize(.small)
          }

          WeekoSettingsStatusPill(
            title: planTitle,
            icon: planIcon,
            tint: planTint,
            compact: true
          )
        }
        .fixedSize()
        }
      )

      if configuration.showsDetail {
        WeekoSettingDivider()

        Label(
          plan.detail,
          systemImage: store.isPro ? "sparkles" : "info.circle"
        )
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 8)
      }
    }
  }

  private var plan: WeekoSubscriptionPlanPresentation {
    configuration.presentation(for: store.plan)
  }

  private var isChecking: Bool {
    store.verificationState == .cached || store.verificationState == .verifying
  }

  private var planTitle: String {
    isChecking ? configuration.verifyingTitle : plan.title
  }

  private var planSubtitle: String {
    isChecking ? configuration.verifyingSubtitle : plan.subtitle
  }

  private var planIcon: String {
    if isChecking { return "clock.arrow.circlepath" }
    return store.isPro ? "checkmark.seal.fill" : "leaf.fill"
  }

  private var planTint: Color {
    if isChecking { return .orange }
    return store.isPro ? .green : plan.tint
  }
}
