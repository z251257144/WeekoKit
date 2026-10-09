import AppKit
import SwiftUI

public struct WeekoMenuPanel<Header: View, Content: View, Footer: View>: View {
  @Environment(\.weekoMacTheme) private var theme

  private let width: CGFloat
  private let cornerRadius: CGFloat
  private let header: Header
  private let content: Content
  private let footer: Footer

  public init(
    width: CGFloat = 352,
    cornerRadius: CGFloat = 15,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer
  ) {
    self.width = width
    self.cornerRadius = cornerRadius
    self.header = header()
    self.content = content()
    self.footer = footer()
  }

  public var body: some View {
    VStack(spacing: 0) {
      header
        .padding(.horizontal, 15)
        .padding(.top, 14)
        .padding(.bottom, 12)

      WeekoMenuDivider()

      content
        .padding(.horizontal, 14)
        .padding(.vertical, 11)

      if Footer.self != EmptyView.self {
        WeekoMenuDivider()

        footer
          .padding(.horizontal, 14)
          .padding(.vertical, 9)
      }
    }
    .frame(width: width)
    .background(WeekoMenuBackground())
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .strokeBorder(Color.white.opacity(0.28), lineWidth: 0.8)
    }
    .tint(theme.accentColor)
  }
}

extension WeekoMenuPanel where Footer == EmptyView {
  public init(
    width: CGFloat = 352,
    cornerRadius: CGFloat = 15,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content
  ) {
    self.init(
      width: width,
      cornerRadius: cornerRadius,
      header: header,
      content: content
    ) {
      EmptyView()
    }
  }
}

public struct WeekoMenuDivider: View {
  private let horizontalInset: CGFloat

  public init(horizontalInset: CGFloat = 14) {
    self.horizontalInset = horizontalInset
  }

  public var body: some View {
    Divider()
      .opacity(0.48)
      .padding(.horizontal, horizontalInset)
  }
}

public struct WeekoMenuSectionHeader<Trailing: View>: View {
  private let title: String
  private let trailing: Trailing

  public init(title: String, @ViewBuilder trailing: () -> Trailing) {
    self.title = title
    self.trailing = trailing()
  }

  public var body: some View {
    HStack(spacing: 8) {
      Text(title)
        .font(.system(size: 12.5, weight: .semibold))
        .foregroundStyle(.secondary)
        .lineLimit(1)

      Spacer(minLength: 8)
      trailing
    }
  }
}

extension WeekoMenuSectionHeader where Trailing == EmptyView {
  public init(title: String) {
    self.init(title: title) { EmptyView() }
  }
}

public struct WeekoMenuBackground: View {
  @Environment(\.weekoMacTheme) private var theme

  public init() {}

  public var body: some View {
    ZStack {
      WeekoMenuVisualEffectView(material: .menu, blendingMode: .behindWindow)
      Color(nsColor: .windowBackgroundColor).opacity(0.78)
      LinearGradient(
        colors: [
          theme.accentColor.opacity(0.09),
          Color.cyan.opacity(0.025),
          .clear,
        ],
        startPoint: .topLeading,
        endPoint: .center
      )
    }
  }
}

public struct WeekoMenuFooterBackground: View {
  @Environment(\.weekoMacTheme) private var theme

  public init() {}

  public var body: some View {
    LinearGradient(
      colors: [
        theme.accentColor.opacity(0.045),
        Color.indigo.opacity(0.018),
        .clear,
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

private struct WeekoMenuVisualEffectView: NSViewRepresentable {
  let material: NSVisualEffectView.Material
  let blendingMode: NSVisualEffectView.BlendingMode

  func makeNSView(context _: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = material
    view.blendingMode = blendingMode
    view.state = .active
    return view
  }

  func updateNSView(_ view: NSVisualEffectView, context _: Context) {
    if view.material != material {
      view.material = material
    }
    if view.blendingMode != blendingMode {
      view.blendingMode = blendingMode
    }
  }
}
