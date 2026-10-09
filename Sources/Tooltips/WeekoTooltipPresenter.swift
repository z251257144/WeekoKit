import AppKit
import SwiftUI

/// 负责管理独立 Tooltip 面板，避免被父 View 或 clipShape 裁剪。
@MainActor
public final class WeekoTooltipPresenter {
  public static let shared = WeekoTooltipPresenter()

  private var window: NSWindow?
  private var hostingController: NSHostingController<AnyView>?
  private var activeOwner: UUID?
  private var generation: UInt64 = 0
  private var currentText = ""
  private var preferredPosition: WeekoTooltipPosition = .top
  private var currentPosition: WeekoTooltipPosition = .top
  private var currentStyle = WeekoTooltipStyle.standard
  private var measuredContentSize: NSSize?

  /// 创建 Tooltip Presenter。
  public init() {}

  /// 显示 Tooltip，并复用已创建的窗口和 hosting controller。
  public func show(
    text: String,
    anchorRect: NSRect,
    position: WeekoTooltipPosition = .top,
    style: WeekoTooltipStyle = .standard,
    owner: UUID
  ) {
    generation &+= 1
    activeOwner = owner

    let window = makeWindowIfNeeded()
    // 每次显示都恢复调用方的首选方向，避免沿用上一次自动翻转结果。
    preferredPosition = position
    updateContent(text: text, position: position, style: style, in: window)
    place(window, around: anchorRect)

    if !window.isVisible || window.alphaValue < 0.99 {
      window.alphaValue = 0
      window.orderFrontRegardless()
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.15
        context.timingFunction = CAMediaTimingFunction(name: .easeOut)
        window.animator().alphaValue = 1
      }
    } else {
      window.orderFrontRegardless()
    }
  }

  /// 锚点移动时更新窗口位置，避免重建内容。
  public func update(anchorRect: NSRect?, owner: UUID) {
    guard activeOwner == owner,
          let anchorRect,
          let window,
          let hostingController,
          window.isVisible
    else {
      return
    }

    let size = measuredSize(in: window, host: hostingController)
    let layout = tooltipLayout(
      for: anchorRect,
      contentSize: size,
      position: preferredPosition,
      gap: currentStyle.gap,
      screen: screen(for: anchorRect)
    )
    if layout.position != currentPosition {
      updateContent(text: currentText, position: layout.position, style: currentStyle, in: window)
      place(window, around: anchorRect)
    } else {
      window.setFrame(layout.frame, display: true)
    }
  }

  /// 隐藏当前拥有者的 Tooltip，并让旧动画失效。
  public func hide(owner: UUID) {
    guard activeOwner == owner else { return }
    activeOwner = nil
    generation &+= 1
    guard let window, window.isVisible else { return }

    let currentGeneration = generation
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.12
      context.timingFunction = CAMediaTimingFunction(name: .easeIn)
      window.animator().alphaValue = 0
    } completionHandler: { [weak self, weak window] in
      MainActor.assumeIsolated {
        guard let self, self.generation == currentGeneration else { return }
        window?.orderOut(nil)
        window?.alphaValue = 1
      }
    }
  }

  /// 创建一次无边框面板，所有 Tooltip 共享该窗口。
  private func makeWindowIfNeeded() -> NSWindow {
    if let window { return window }

    let window = NSPanel(
      contentRect: .zero,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.isOpaque = false
    window.backgroundColor = .clear
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.level = .popUpMenu
    window.hidesOnDeactivate = false
    window.isReleasedWhenClosed = false
    self.window = window
    return window
  }

  /// 更新 Tooltip 内容并触发布局测量。
  private func updateContent(
    text: String,
    position: WeekoTooltipPosition,
    style: WeekoTooltipStyle,
    in window: NSWindow
  ) {
    currentText = text
    currentPosition = position
    currentStyle = style
    measuredContentSize = nil

    let content = AnyView(
      WeekoTooltipContent(text: text, position: position, style: style)
    )
    if let hostingController {
      hostingController.rootView = content
    } else {
      let hostingController = NSHostingController(rootView: content)
      hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
      window.contentViewController = hostingController
      self.hostingController = hostingController
    }
    hostingController?.view.layoutSubtreeIfNeeded()
  }

  /// 计算并应用 Tooltip 的最终屏幕位置，必要时自动翻转方向。
  private func place(_ window: NSWindow, around anchorRect: NSRect) {
    var size = measuredSize(in: window, host: hostingController)
    var layout = tooltipLayout(
      for: anchorRect,
      contentSize: size,
      position: preferredPosition,
      gap: currentStyle.gap,
      screen: screen(for: anchorRect)
    )

    if layout.position != currentPosition {
      updateContent(
        text: currentText,
        position: layout.position,
        style: currentStyle,
        in: window
      )
      size = measuredSize(in: window, host: hostingController)
      layout = tooltipLayout(
        for: anchorRect,
        contentSize: size,
        position: layout.position,
        gap: currentStyle.gap,
        screen: screen(for: anchorRect)
      )
    }
    window.setFrame(layout.frame, display: true)
  }

  /// 读取 hosting controller 的最佳尺寸，并保证尺寸有效。
  private func measuredSize(
    in window: NSWindow,
    host: NSHostingController<AnyView>?
  ) -> NSSize {
    if let measuredContentSize {
      return measuredContentSize
    }

    host?.view.layoutSubtreeIfNeeded()
    let size = host?.view.fittingSize ?? NSSize(width: 120, height: 32)
    let normalizedSize = NSSize(width: max(1, size.width), height: max(1, size.height))
    measuredContentSize = normalizedSize
    return normalizedSize
  }

  /// 找到包含锚点的屏幕，支持多屏布局。
  private func screen(for anchorRect: NSRect) -> NSScreen? {
    NSScreen.screens.first { $0.visibleFrame.intersects(anchorRect) }
      ?? NSScreen.main
      ?? NSScreen.screens.first
  }

  private struct TooltipLayout {
    let frame: NSRect
    let position: WeekoTooltipPosition
  }

  /// 根据屏幕边界计算 Tooltip 的方向、横向吸附和纵向位置。
  private func tooltipLayout(
    for anchorRect: NSRect,
    contentSize: NSSize,
    position: WeekoTooltipPosition,
    gap: CGFloat,
    screen: NSScreen?
  ) -> TooltipLayout {
    let visibleFrame = screen?.visibleFrame ?? anchorRect.insetBy(dx: -1000, dy: -1000)
    let inset: CGFloat = 8
    let x = min(
      max(anchorRect.midX - contentSize.width / 2, visibleFrame.minX + inset),
      max(visibleFrame.minX + inset, visibleFrame.maxX - contentSize.width - inset)
    )
    let preferredY = position.isTop
      ? anchorRect.maxY + gap
      : anchorRect.minY - contentSize.height - gap
    let alternateY = position.isTop
      ? anchorRect.minY - contentSize.height - gap
      : anchorRect.maxY + gap
    let preferredFrame = NSRect(
      x: x,
      y: preferredY,
      width: contentSize.width,
      height: contentSize.height
    )
    let alternateFrame = NSRect(
      x: x,
      y: alternateY,
      width: contentSize.width,
      height: contentSize.height
    )
    let usePreferred = visibleFrame.contains(preferredFrame) || !visibleFrame.intersects(alternateFrame)
    let selectedFrame = usePreferred ? preferredFrame : alternateFrame
    let selectedPosition = usePreferred ? position : (position == .top ? .bottom : .top)
    let y = min(
      max(selectedFrame.minY, visibleFrame.minY + inset),
      max(visibleFrame.minY + inset, visibleFrame.maxY - contentSize.height - inset)
    )
    return TooltipLayout(
      frame: NSRect(x: x, y: y, width: contentSize.width, height: contentSize.height),
      position: selectedPosition
    )
  }
}

/// Tooltip 内容视图，放在独立窗口中渲染。
struct WeekoTooltipContent: View {
  let text: String
  let position: WeekoTooltipPosition
  let style: WeekoTooltipStyle

  /// 构建 Tooltip 文本和背景。
  var body: some View {
    Text(text)
      .font(.system(size: style.fontSize, weight: .medium, design: .rounded))
      .foregroundStyle(.primary)
      .multilineTextAlignment(.leading)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: style.maximumWidth, alignment: .leading)
      .padding(.horizontal, style.horizontalPadding)
      .padding(.vertical, style.verticalPadding)
      .padding(.bottom, position == .top ? style.arrowSize.height : 0)
      .padding(.top, position == .bottom ? style.arrowSize.height : 0)
      .background {
        WeekoTooltipBubble(
          radius: style.cornerRadius,
          arrowSize: style.arrowSize,
          position: position
        )
        .fill(background(for: style.background))
        .shadow(
          color: Color.black.opacity(style.shadowOpacity),
          radius: 6,
          x: 0,
          y: 2
        )
        .overlay {
          WeekoTooltipBubble(
            radius: style.cornerRadius,
            arrowSize: style.arrowSize,
            position: position
          )
          .stroke(
            Color.primary.opacity(style.borderOpacity),
            lineWidth: 1
          )
        }
      }
  }

  /// 将公开背景配置转换为 SwiftUI ShapeStyle。
  private func background(for background: WeekoTooltipBackground) -> AnyShapeStyle {
    switch background {
    case .regularMaterial:
      AnyShapeStyle(Material.regular)
    case .thickMaterial:
      AnyShapeStyle(Material.thick)
    case let .solid(color):
      AnyShapeStyle(color)
    }
  }
}
