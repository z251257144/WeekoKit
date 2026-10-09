import AppKit
import SwiftUI

public struct WeekoSettingsShell<ID: Hashable, Accessory: View, Detail: View>: View {
  @Environment(\.weekoMacTheme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding private var selection: ID

  private let applicationName: String
  private let applicationIcon: NSImage?
  private let groups: [WeekoSettingsNavigationGroup<ID>]
  private let closeTitle: String
  private let onClose: () -> Void
  private let navigationAccessory: (ID) -> Accessory
  private let detail: (ID) -> Detail

  public init(
    applicationName: String,
    applicationIcon: NSImage? = nil,
    groups: [WeekoSettingsNavigationGroup<ID>],
    selection: Binding<ID>,
    closeTitle: String = WeekoLocalization.packageString("weeko_common_close"),
    onClose: @escaping () -> Void,
    @ViewBuilder navigationAccessory: @escaping (ID) -> Accessory,
    @ViewBuilder detail: @escaping (ID) -> Detail
  ) {
    self.applicationName = applicationName
    self.applicationIcon = applicationIcon
    self.groups = groups
    _selection = selection
    self.closeTitle = closeTitle
    self.onClose = onClose
    self.navigationAccessory = navigationAccessory
    self.detail = detail
  }

  public var body: some View {
    ZStack {
      Rectangle().fill(.regularMaterial)
      Color(nsColor: .windowBackgroundColor).opacity(0.62)

      HStack(spacing: 0) {
        WeekoSettingsMenu(
          applicationName: applicationName,
          applicationIcon: applicationIcon,
          groups: groups,
          selection: $selection,
          navigationAccessory: navigationAccessory
        )
        Divider().opacity(0.45)
        detailPane
      }
    }
    .clipShape(
      RoundedRectangle(cornerRadius: theme.windowCornerRadius, style: .continuous)
    )
    .overlay {
      RoundedRectangle(cornerRadius: theme.windowCornerRadius, style: .continuous)
        .strokeBorder(Color.white.opacity(0.30), lineWidth: 0.8)
    }
    .overlay(alignment: .topTrailing) {
      closeButton
        .padding(.top, 28)
        .padding(.trailing, 18)
    }
    .onExitCommand(perform: onClose)
  }

  private var detailPane: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let selectedItem {
        HStack(spacing: 12) {
          Image(systemName: selectedItem.systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(selectedItem.tint)
            .frame(width: 38, height: 38)
            .background(
              selectedItem.tint.opacity(0.11),
              in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )

          Text(selectedItem.title)
            .font(.system(size: 21, weight: .bold))
            .lineLimit(1)

          Spacer(minLength: 48)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 10)
      }

      detail(selection)
        .id(selection)
        .transition(.opacity)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: selection)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var closeButton: some View {
    Button(action: onClose) {
      Image(systemName: "xmark")
        .font(.system(size: 12, weight: .bold))
        .frame(width: 30, height: 30)
    }
    .buttonStyle(WeekoCircularIconButtonStyle())
    .keyboardShortcut(.cancelAction)
    .help(closeTitle)
    .accessibilityLabel(closeTitle)
  }

  private var selectedItem: WeekoSettingsNavigationItem<ID>? {
    groups.lazy.flatMap(\.items).first { $0.id == selection }
  }
}

extension WeekoSettingsShell where Accessory == EmptyView {
  public init(
    applicationName: String,
    applicationIcon: NSImage? = nil,
    groups: [WeekoSettingsNavigationGroup<ID>],
    selection: Binding<ID>,
    closeTitle: String = WeekoLocalization.packageString("weeko_common_close"),
    onClose: @escaping () -> Void,
    @ViewBuilder detail: @escaping (ID) -> Detail
  ) {
    self.init(
      applicationName: applicationName,
      applicationIcon: applicationIcon,
      groups: groups,
      selection: selection,
      closeTitle: closeTitle,
      onClose: onClose,
      navigationAccessory: { _ in EmptyView() },
      detail: detail
    )
  }
}

public struct WeekoSettingsFormPage<Content: View>: View {
  private let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    Form {
      content
    }
    .formStyle(.grouped)
    .scrollContentBackground(.hidden)
    .padding(.horizontal, 12)
    .padding(.bottom, 10)
  }
}

public struct WeekoSettingsScrollPage<Content: View>: View {
  private let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        content
      }
      .padding(24)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
