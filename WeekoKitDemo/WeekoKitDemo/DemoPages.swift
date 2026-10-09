import AppKit
import SwiftUI
import WeekoKit

struct DemoComponentsPage: View {
  @Environment(\.weekoMacTheme) private var theme
  @State private var interfaceDensity = DemoDensity.comfortable
  @State private var opacity = 0.72
  @State private var showsNotice = true

  var body: some View {
    WeekoSettingsFormPage {
      WeekoSettingSection(DemoText.localized("components_appearance"), icon: "paintbrush") {
        WeekoSettingActionRow(
          icon: "rectangle.3.group",
          tint: .blue,
          title: DemoText.localized("components_interface_density"),
          subtitle: DemoText.localized("components_interface_density_subtitle")
        ) {
          Picker(DemoText.localized("components_interface_density"), selection: $interfaceDensity) {
            ForEach(DemoDensity.allCases) { density in
              Text(density.title).tag(density)
            }
          }
          .labelsHidden()
//          .frame(width: 132)
        }

        WeekoSettingDivider()

        WeekoSettingActionRow(
          icon: "circle.lefthalf.filled",
          tint: .purple,
          title: DemoText.localized("components_surface_opacity"),
          subtitle: DemoText.localized("components_surface_opacity_subtitle")
        ) {
          HStack(spacing: 8) {
            Slider(value: $opacity, in: 0.35...1)
            Text(opacity, format: .percent.precision(.fractionLength(0)))
              .font(.system(size: 11, design: .monospaced))
              .foregroundStyle(.secondary)
              .frame(width: 34, alignment: .trailing)
          }
//          .frame(width: 180)
        }
      }

      WeekoSettingSection(DemoText.localized("components_status"), icon: "checkmark.seal") {
        WeekoSettingActionRow(
          icon: "icloud.and.arrow.up",
          tint: .green,
          title: DemoText.localized("components_cloud_sync"),
          subtitle: DemoText.localized("components_cloud_sync_subtitle")
        ) {
          WeekoSettingsStatusPill(
            title: DemoText.localized("components_up_to_date"),
            icon: "checkmark.circle.fill",
            tint: .green
          )
        }

        WeekoSettingDivider()

        WeekoSettingActionRow(
          icon: "wrench.and.screwdriver",
          tint: theme.accentColor,
          title: DemoText.localized("components_notice"),
          subtitle: DemoText.localized("components_notice_subtitle")
        ) {
          Button {
            withAnimation(.easeInOut(duration: 0.16)) {
              showsNotice.toggle()
            }
          } label: {
            Label(
              showsNotice
                ? DemoText.localized("components_hide")
                : DemoText.localized("components_show"),
              systemImage: "rectangle.badge.checkmark"
            )
          }
          .buttonStyle(WeekoSettingsActionButtonStyle(tint: theme.accentColor))
        }

        if showsNotice {
          WeekoSettingDivider()
          WeekoSettingsNotice(
            icon: "info.circle.fill",
            tint: .blue,
            message:
              DemoText.localized("components_notice_message")
          )
          .padding(.vertical, 10)
        }
      }
    }
  }
}

struct DemoSettingsPage: View {
  @StateObject private var store: WeekoSettingsStore

  init() {
    _store = StateObject(
      wrappedValue: WeekoSettingsStore(
        applicationName: "WeekoKit Demo"
      )
    )
  }

  var body: some View {
    WeekoSettingsPage(store: store)
  }
}

private enum DemoDensity: String, CaseIterable, Identifiable {
  case compact
  case comfortable
  case spacious

  var id: String { rawValue }

  var title: String {
    DemoText.localized("density_\(rawValue)")
  }
}

struct DemoPermissionPage: View {
  @ObservedObject var screenRecordingCoordinator: WeekoPermissionCoordinator
  @ObservedObject var microphoneCoordinator: WeekoPermissionCoordinator
  @ObservedObject var notificationCoordinator: WeekoPermissionCoordinator

  init(
    screenRecordingCoordinator: WeekoPermissionCoordinator,
    microphoneCoordinator: WeekoPermissionCoordinator,
    notificationCoordinator: WeekoPermissionCoordinator
  ) {
    self.screenRecordingCoordinator = screenRecordingCoordinator
    self.microphoneCoordinator = microphoneCoordinator
    self.notificationCoordinator = notificationCoordinator
  }

  var body: some View {
    WeekoSettingsFormPage {
      WeekoPermissionSettingsSection(
        WeekoLocalization.packageString("weeko_permissions_section_title"),
        icon: "lock.shield",
        items: [
          permissionItem(
            kind: .screenRecording,
            coordinator: screenRecordingCoordinator
          ),
          permissionItem(
            kind: .microphone,
            coordinator: microphoneCoordinator
          ),
          permissionItem(
            kind: .notifications,
            coordinator: notificationCoordinator
          ),
        ]
      )
    }
  }

  private func permissionItem(
    kind: DemoPermissionKind,
    coordinator: WeekoPermissionCoordinator
  ) -> WeekoPermissionSettingsItem {
    WeekoPermissionSettingsItem(
      id: kind.rawValue,
      icon: kind.systemImage,
      tint: kind.tint,
      title: kind.title,
      subtitle: kind.subtitle,
      coordinator: coordinator
    ) {
      DemoPermissionWindowController.controller(for: kind).show()
    }
  }
}

enum DemoPermissionKind: String {
  case screenRecording
  case microphone
  case notifications

  var title: String {
    localizationKind.title
  }

  var systemImage: String {
    switch self {
    case .screenRecording: return "record.circle.fill"
    case .microphone: return "mic.fill"
    case .notifications: return "bell.badge.fill"
    }
  }

  var tint: Color {
    switch self {
    case .screenRecording: return .teal
    case .microphone: return .purple
    case .notifications: return .orange
    }
  }

  var handlesDeniedPermissionInline: Bool {
    switch self {
    case .screenRecording, .microphone:
      true
    case .notifications:
      false
    }
  }

  var subtitle: String {
    localizationKind.subtitle
  }

  var localizationKind: WeekoPermissionKind {
    switch self {
    case .screenRecording: return .screenRecording
    case .microphone: return .microphone
    case .notifications: return .notifications
    }
  }

}

struct DemoPermissionPromptWindow: View {
  let kind: DemoPermissionKind
  let permissionStore: DemoPermissionStore
  let onDismiss: () -> Void

  var body: some View {
    WeekoPermissionPromptPage(
      coordinator: coordinator,
      configuration: permissionConfiguration(for: kind),
      onDismiss: onDismiss
    )
    .frame(width: 600, height: 500)
    .ignoresSafeArea()
    .weekoMacTheme(
      WeekoMacTheme(accentColor: Color(red: 0.18, green: 0.49, blue: 0.91))
    )
    .background(DemoWindowConfigurator())
  }

  private var coordinator: WeekoPermissionCoordinator {
    switch kind {
    case .screenRecording:
      permissionStore.screenRecordingCoordinator
    case .microphone:
      permissionStore.microphoneCoordinator
    case .notifications:
      permissionStore.notificationCoordinator
    }
  }
}

private func permissionConfiguration(
  for kind: DemoPermissionKind
) -> WeekoPermissionPromptConfiguration {
  let base = WeekoPermissionPromptConfiguration.weekoDefault(
    applicationName: "WeekoKit Demo",
    kind: kind.localizationKind
  )

  return WeekoPermissionPromptConfiguration(
    applicationName: base.applicationName,
    headerTitle: base.headerTitle,
    requestTitle: base.requestTitle,
    requestMessage: base.requestMessage,
    authorizedTitle: base.authorizedTitle,
    authorizedMessage: base.authorizedMessage,
    deniedMessage: base.deniedMessage,
    unavailableMessage: base.unavailableMessage,
    instructions: base.instructions,
    requestButtonTitle: base.requestButtonTitle,
    openSettingsButtonTitle: base.openSettingsButtonTitle,
    doneButtonTitle: base.doneButtonTitle,
    checkingTitle: base.checkingTitle,
    closeTitle: base.closeTitle,
    requestSystemImage: kind.systemImage,
    showsDeniedNotice: !kind.handlesDeniedPermissionInline,
    opensSystemSettingsAfterRequestFailure: kind.handlesDeniedPermissionInline
  )
}

struct DemoCommercePage: View {
  @StateObject private var store: WeekoEntitlementStore

  init() {
    _store = StateObject(
      wrappedValue: WeekoEntitlementStore(
        annualProductID: "net.weeko.focus.yearly",
        lifetimeProductID: "net.weeko.focus.lifetime"
      )
    )
  }

  var body: some View {
    WeekoSettingsFormPage {
      WeekoSubscriptionView(store: store)
    }
  }
}

struct DemoAboutPage: View {
  var body: some View {
    WeekoSettingsFormPage {
      WeekoAboutPage(configuration: configuration)
    }
  }

  private var configuration: WeekoAboutPageConfiguration {
    WeekoAboutPageConfiguration(
      metadata: WeekoApplicationMetadata(
        name: "WeekoKit Demo",
        version: "1.0",
        build: "1"
      ),
      identitySectionTitle: WeekoLocalization.packageString("weeko_about_identity_section"),
      slogan: DemoText.localized("about_slogan"),
      subtitle: DemoText.localized("about_platform"),
      versionTitle: WeekoLocalization.packageString("weeko_about_version"),
      buildTitle: WeekoLocalization.packageString("weeko_about_build"),
      copyVersionTitle: WeekoLocalization.packageString("weeko_about_copy_version"),
      copiedTitle: WeekoLocalization.packageString("weeko_about_copied"),
      copyFailedMessage: WeekoLocalization.packageString("weeko_about_copy_failed"),
      openLinkTitle: DemoText.localized("about_open_browser"),
      openLinkFailedMessage: WeekoLocalization.packageString("weeko_about_open_link_failed"),
      dismissFeedbackTitle: WeekoLocalization.packageString("weeko_common_dismiss"),
      copyright: "Copyright © \(Calendar.current.component(.year, from: Date())) Weeko",
      sections: [
        WeekoAboutSection(
          id: "support",
          title: DemoText.localized("about_support"),
          systemImage: "person.crop.circle.badge.questionmark",
          rows: [
            WeekoAboutRow(
              icon: "safari",
              tint: .blue,
              title: DemoText.localized("about_website"),
              subtitle: DemoText.localized("about_website_subtitle"),
              url: URL(string: "https://www.weeko.net")
            ),
            WeekoAboutRow(
              icon: "envelope.badge",
              tint: .teal,
              title: DemoText.localized("about_feedback"),
              subtitle: DemoText.localized("about_feedback_subtitle"),
              url: URL(string: "https://www.weeko.net/feedback")
            ),
          ]
        ),
        WeekoAboutSection(
          id: "legal",
          title: DemoText.localized("about_legal"),
          systemImage: "doc.text",
          rows: [
            WeekoAboutRow(
              icon: "hand.raised.fill",
              tint: .green,
              title: WeekoSubscriptionText.localized("subscription.legal.privacy"),
              subtitle: DemoText.localized("about_privacy_subtitle"),
              url: URL(string: "https://www.weeko.net/privacy")
            ),
            WeekoAboutRow(
              icon: "doc.text.fill",
              tint: .indigo,
              title: WeekoSubscriptionText.localized("subscription.legal.terms"),
              subtitle: DemoText.localized("about_terms_subtitle"),
              url: URL(string: "https://www.weeko.net/terms")
            ),
          ]
        ),
      ]
    )
  }
}
