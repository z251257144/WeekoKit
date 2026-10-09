import SwiftUI

public struct WeekoSubscriptionHighlightsSection: View {
  @Environment(\.weekoMacTheme) private var theme
  private let configuration: WeekoSubscriptionHighlightsConfiguration
  private let plan: WeekoPlan

  public init(
    configuration: WeekoSubscriptionHighlightsConfiguration = .weekoDefault(),
    plan: WeekoPlan = .free
  ) {
    self.configuration = configuration
    self.plan = plan
  }

  public var body: some View {
    VStack(spacing: 14) {
      hero
      features
    }
  }

  private var hero: some View {
    HStack(alignment: .center, spacing: 14) {
      Image(systemName: heroIcon)
        .font(.system(size: 19, weight: .bold))
        .foregroundStyle(.white)
        .frame(width: 48, height: 48)
        .background(heroTint, in: Circle())
        .weekoSubscriptionBreatheEffect(isEnabled: !plan.isPro)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 5) {
        Text(heroTitle)
          .font(.system(size: 18, weight: .bold))

        Text(heroSubtitle)
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: 7) {
          WeekoSettingsStatusPill(
            title: primaryBadgeTitle,
            icon: plan.isPro ? "checkmark.circle.fill" : "clock.arrow.circlepath",
            tint: heroTint
          )

          WeekoSettingsStatusPill(
            title: secondaryBadgeTitle,
            icon: plan.isPro ? "heart.fill" : "internaldrive.fill",
            tint: .green
          )
        }
        .padding(.top, 2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity)
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(heroTint.opacity(0.055))
    )
    .overlay {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .strokeBorder(heroTint.opacity(0.11), lineWidth: 0.8)
    }
  }

  private var heroIcon: String {
    plan.isPro ? "checkmark.seal.fill" : "sparkles"
  }

  private var heroTint: Color {
    plan.isPro ? .green : theme.accentColor
  }

  private var heroTitle: String {
    plan.isPro ? configuration.proTitle : configuration.title
  }

  private var heroSubtitle: String {
    plan.isPro ? configuration.proSubtitle : configuration.subtitle
  }

  private var primaryBadgeTitle: String {
    plan.isPro ? configuration.proPrimaryBadgeTitle : configuration.historyBadgeTitle
  }

  private var secondaryBadgeTitle: String {
    plan.isPro ? configuration.proSecondaryBadgeTitle : configuration.localBadgeTitle
  }

  private var features: some View {
    VStack(spacing: 0) {
      ForEach(Array(configuration.features.enumerated()), id: \.element.id) { index, feature in
        if index > 0 {
          WeekoSettingDivider()
        }
        WeekoSettingRow(
          icon: feature.icon,
          tint: feature.tint,
          title: feature.title,
          subtitle: feature.subtitle
        )
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private extension View {
  @ViewBuilder
  func weekoSubscriptionBreatheEffect(isEnabled: Bool) -> some View {
    if isEnabled, #available(macOS 15.0, *) {
      symbolEffect(.breathe, options: .repeating.speed(0.35))
    } else {
      self
    }
  }
}
