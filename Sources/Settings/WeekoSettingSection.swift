import SwiftUI

public struct WeekoSettingSection<Content: View, Footer: View>: View {
  private let title: String
  private let icon: String
  private let content: Content
  private let footer: Footer

  public init(
    _ title: String,
    icon: String,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer
  ) {
    self.title = title
    self.icon = icon
    self.content = content()
    self.footer = footer()
  }

  @ViewBuilder
  public var body: some View {
    if Footer.self == EmptyView.self {
      Section {
        sectionContent
      } header: {
        sectionHeader
      }
    } else {
      Section {
        sectionContent
      } header: {
        sectionHeader
      } footer: {
        footer
      }
    }
  }

  private var sectionContent: some View {
    VStack(spacing: 0) {
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .listRowInsets(EdgeInsets(top: 1, leading: 10, bottom: 1, trailing: 10))
  }

  private var sectionHeader: some View {
    Label(title, systemImage: icon)
      .font(.system(size: WeekoSettingMetrics.titleFontSize, weight: .bold))
      .lineLimit(1)
      .minimumScaleFactor(0.86)
      .foregroundStyle(.secondary)
      .padding(.bottom, 4)
  }
}

extension WeekoSettingSection where Footer == EmptyView {
  public init(
    _ title: String,
    icon: String,
    @ViewBuilder content: () -> Content
  ) {
    self.init(title, icon: icon, content: content) {
      EmptyView()
    }
  }
}
