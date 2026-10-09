import SwiftUI

public struct WeekoSubscriptionFeature: Identifiable {
  public let id: String
  public let icon: String
  public let tint: Color
  public let title: String
  public let subtitle: String

  public init(
    id: String,
    icon: String,
    tint: Color,
    title: String,
    subtitle: String
  ) {
    self.id = id
    self.icon = icon
    self.tint = tint
    self.title = title
    self.subtitle = subtitle
  }
}

public struct WeekoSubscriptionHighlightsConfiguration {
  public let title: String
  public let subtitle: String
  public let historyBadgeTitle: String
  public let localBadgeTitle: String
  public let proTitle: String
  public let proSubtitle: String
  public let proPrimaryBadgeTitle: String
  public let proSecondaryBadgeTitle: String
  public let features: [WeekoSubscriptionFeature]

  public init(
    title: String,
    subtitle: String,
    historyBadgeTitle: String,
    localBadgeTitle: String,
    proTitle: String? = nil,
    proSubtitle: String? = nil,
    proPrimaryBadgeTitle: String? = nil,
    proSecondaryBadgeTitle: String? = nil,
    features: [WeekoSubscriptionFeature]
  ) {
    self.title = title
    self.subtitle = subtitle
    self.historyBadgeTitle = historyBadgeTitle
    self.localBadgeTitle = localBadgeTitle
    self.proTitle = proTitle ?? title
    self.proSubtitle = proSubtitle ?? subtitle
    self.proPrimaryBadgeTitle = proPrimaryBadgeTitle ?? historyBadgeTitle
    self.proSecondaryBadgeTitle = proSecondaryBadgeTitle ?? localBadgeTitle
    self.features = features
  }

  public static func weekoDefault() -> Self {
    Self(
      title: WeekoSubscriptionText.localized("subscription.highlights.title"),
      subtitle: WeekoSubscriptionText.localized("subscription.highlights.subtitle"),
      historyBadgeTitle: WeekoSubscriptionText.localized(
        "subscription.highlights.history_badge"
      ),
      localBadgeTitle: WeekoSubscriptionText.localized(
        "subscription.highlights.local_badge"
      ),
      proTitle: WeekoSubscriptionText.localized("subscription.highlights.pro.title"),
      proSubtitle: WeekoSubscriptionText.localized("subscription.highlights.pro.subtitle"),
      proPrimaryBadgeTitle: WeekoSubscriptionText.localized(
        "subscription.highlights.pro.primary_badge"
      ),
      proSecondaryBadgeTitle: WeekoSubscriptionText.localized(
        "subscription.highlights.pro.secondary_badge"
      ),
      features: [
        WeekoSubscriptionFeature(
          id: "insights",
          icon: "chart.xyaxis.line",
          tint: .accentColor,
          title: WeekoSubscriptionText.localized("subscription.feature.insights.title"),
          subtitle: WeekoSubscriptionText.localized("subscription.feature.insights.subtitle")
        ),
        WeekoSubscriptionFeature(
          id: "local",
          icon: "square.stack.3d.up.fill",
          tint: .orange,
          title: WeekoSubscriptionText.localized("subscription.feature.local.title"),
          subtitle: WeekoSubscriptionText.localized("subscription.feature.local.subtitle")
        ),
        WeekoSubscriptionFeature(
          id: "support",
          icon: "speaker.wave.2.fill",
          tint: .pink,
          title: WeekoSubscriptionText.localized("subscription.feature.support.title"),
          subtitle: WeekoSubscriptionText.localized("subscription.feature.support.subtitle")
        ),
      ]
    )
  }
}

public struct WeekoSubscriptionPlanPresentation {
  public let title: String
  public let subtitle: String
  public let detail: String
  public let icon: String
  public let tint: Color

  public init(
    title: String,
    subtitle: String,
    detail: String,
    icon: String,
    tint: Color
  ) {
    self.title = title
    self.subtitle = subtitle
    self.detail = detail
    self.icon = icon
    self.tint = tint
  }
}

public struct WeekoSubscriptionPlanConfiguration {
  public let sectionTitle: String
  public let sectionIcon: String
  public let displayTitle: String?
  public let verifyingTitle: String
  public let verifyingSubtitle: String
  public let showsDetail: Bool
  public let free: WeekoSubscriptionPlanPresentation
  public let annual: WeekoSubscriptionPlanPresentation
  public let lifetime: WeekoSubscriptionPlanPresentation

  public init(
    sectionTitle: String,
    sectionIcon: String = "checkmark.seal.fill",
    verifyingTitle: String,
    free: WeekoSubscriptionPlanPresentation,
    annual: WeekoSubscriptionPlanPresentation,
    lifetime: WeekoSubscriptionPlanPresentation,
    displayTitle: String? = nil,
    verifyingSubtitle: String? = nil,
    showsDetail: Bool = false
  ) {
    self.sectionTitle = sectionTitle
    self.sectionIcon = sectionIcon
    self.displayTitle = displayTitle
    self.verifyingTitle = verifyingTitle
    self.verifyingSubtitle = verifyingSubtitle ?? verifyingTitle
    self.showsDetail = showsDetail
    self.free = free
    self.annual = annual
    self.lifetime = lifetime
  }

  public static func weekoDefault() -> Self {
    Self(
      sectionTitle: WeekoSubscriptionText.localized("subscription.plan.section"),
      sectionIcon: "checkmark.seal.fill",
      verifyingTitle: WeekoSubscriptionText.localized("subscription.plan.verifying"),
      free: WeekoSubscriptionPlanPresentation(
        title: WeekoSubscriptionText.localized("subscription.plan.free.title"),
        subtitle: WeekoSubscriptionText.localized("subscription.plan.free.subtitle"),
        detail: WeekoSubscriptionText.localized("subscription.plan.free.detail"),
        icon: "leaf.fill",
        tint: .accentColor
      ),
      annual: WeekoSubscriptionPlanPresentation(
        title: WeekoSubscriptionText.localized("subscription.plan.annual.title"),
        subtitle: WeekoSubscriptionText.localized("subscription.plan.annual.subtitle"),
        detail: WeekoSubscriptionText.localized("subscription.plan.annual.detail"),
        icon: "calendar.badge.checkmark",
        tint: .blue
      ),
      lifetime: WeekoSubscriptionPlanPresentation(
        title: WeekoSubscriptionText.localized("subscription.plan.lifetime.title"),
        subtitle: WeekoSubscriptionText.localized("subscription.plan.lifetime.subtitle"),
        detail: WeekoSubscriptionText.localized("subscription.plan.lifetime.detail"),
        icon: "seal.fill",
        tint: .purple
      ),
      displayTitle: WeekoSubscriptionText.localized("subscription.plan.current.title"),
      verifyingSubtitle: WeekoSubscriptionText.localized(
        "subscription.plan.verifying.subtitle"
      )
    )
  }

  public func presentation(for plan: WeekoPlan) -> WeekoSubscriptionPlanPresentation {
    switch plan {
    case .free: return free
    case .proAnnual: return annual
    case .proLifetime: return lifetime
    }
  }
}
