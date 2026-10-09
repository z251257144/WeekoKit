import AppKit
import SwiftUI

/// 保存锚点最新屏幕坐标，确保延迟显示时读取的是当前 frame。
private final class WeekoTooltipAnchorBox {
  var frame: NSRect?
  private var trackingSetter: ((Bool) -> Void)?
  private var frameReader: (() -> NSRect?)?

  /// 绑定底层锚点视图，供悬停状态控制监听生命周期。
  func attach(
    trackingSetter: @escaping (Bool) -> Void,
    frameReader: @escaping () -> NSRect?
  ) {
    self.trackingSetter = trackingSetter
    self.frameReader = frameReader
  }

  /// 只在 Tooltip 已显示时监听窗口移动和布局变化。
  func setTracking(_ isTracking: Bool) {
    trackingSetter?(isTracking)
  }

  /// 在 Tooltip 即将显示时同步读取最新屏幕坐标。
  @discardableResult
  func refreshFrame() -> NSRect? {
    let nextFrame = frameReader?()
    frame = nextFrame
    return nextFrame
  }

  /// 锚点视图销毁时清理闭包，避免保留无效的 AppKit 对象。
  func detach() {
    trackingSetter = nil
    frameReader = nil
  }
}

/// 将 SwiftUI View 的实际屏幕坐标传给独立 Tooltip 窗口。
private struct WeekoTooltipAnchorView: NSViewRepresentable {
  let anchorBox: WeekoTooltipAnchorBox
  let onChange: (NSRect?) -> Void

  /// 创建用于读取屏幕坐标的 NSView。
  func makeNSView(context _: Context) -> AnchorNSView {
    let nsView = AnchorNSView(onChange: onChange)
    anchorBox.attach(
      trackingSetter: { [weak nsView] isTracking in
        nsView?.setTracking(isTracking)
      },
      frameReader: { [weak nsView] in
        nsView?.currentScreenFrame(updateCache: true)
      }
    )
    return nsView
  }

  /// SwiftUI 更新时同步回调和最新坐标。
  func updateNSView(_ nsView: AnchorNSView, context _: Context) {
    nsView.onChange = onChange
    anchorBox.attach(
      trackingSetter: { [weak nsView] isTracking in
        nsView?.setTracking(isTracking)
      },
      frameReader: { [weak nsView] in
        nsView?.currentScreenFrame(updateCache: true)
      }
    )
  }

  final class AnchorNSView: NSView {
    var onChange: (NSRect?) -> Void
    private var isTracking = false
    private var lastFrame: NSRect?
    private var pendingFrame: NSRect?
    private var frameReportScheduled = false
    private var windowObservers: [NSObjectProtocol] = []

    /// 创建坐标锚点视图。
    init(onChange: @escaping (NSRect?) -> Void) {
      self.onChange = onChange
      super.init(frame: .zero)
      wantsLayer = false
    }

    @available(*, unavailable)
    /// 不支持从 storyboard 解码 Tooltip 锚点。
    required init?(coder _: NSCoder) {
      fatalError()
    }

    /// View 加入窗口后立即报告一次坐标。
    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      removeWindowObservers()
      installWindowObserversIfNeeded()
      if isTracking {
        reportFrame(force: true)
      }
    }

    /// 切换窗口移动监听，只为正在显示的 Tooltip 保持坐标更新。
    func setTracking(_ isTracking: Bool) {
      guard self.isTracking != isTracking else { return }
      self.isTracking = isTracking
      removeWindowObservers()
      if isTracking {
        installWindowObserversIfNeeded()
        reportFrame()
      }
    }

    /// 为正在显示的 Tooltip 绑定当前窗口的移动和尺寸通知。
    private func installWindowObserversIfNeeded() {
      guard isTracking, let window else { return }
      let notificationCenter = NotificationCenter.default
      windowObservers = [
        notificationCenter.addObserver(
          forName: NSWindow.didMoveNotification,
          object: window,
          queue: .main
        ) { [weak self] _ in
          self?.reportFrame()
        },
        notificationCenter.addObserver(
          forName: NSWindow.didResizeNotification,
          object: window,
          queue: .main
        ) { [weak self] _ in
          self?.reportFrame()
        },
      ]
    }

    /// 移除旧窗口的观察者，避免窗口切换后重复回调。
    private func removeWindowObservers() {
      let notificationCenter = NotificationCenter.default
      windowObservers.forEach(notificationCenter.removeObserver)
      windowObservers.removeAll()
    }

    /// 锚点销毁时释放窗口通知观察者。
    deinit {
      removeWindowObservers()
    }

    /// 布局变化时更新屏幕坐标。
    override func layout() {
      super.layout()
      if isTracking {
        reportFrame()
      }
    }

    /// 读取当前屏幕坐标；延迟显示阶段也可按需同步调用一次并写入缓存。
    func currentScreenFrame(updateCache: Bool = false) -> NSRect? {
      if let window {
        let windowFrame = convert(bounds, to: nil)
        let screenFrame = window.convertToScreen(windowFrame).standardized
        if updateCache {
          lastFrame = screenFrame
        }
        return screenFrame
      }
      if updateCache {
        lastFrame = nil
      }
      return nil
    }

    /// 只在坐标变化或主动刷新时回调，减少窗口重排。
    private func reportFrame(force: Bool = false) {
      guard isTracking else { return }
      let nextFrame = currentScreenFrame()
      guard force || nextFrame != lastFrame else { return }
      lastFrame = nextFrame
      pendingFrame = nextFrame
      guard !frameReportScheduled else { return }
      frameReportScheduled = true
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.frameReportScheduled = false
        let frame = self.pendingFrame
        self.pendingFrame = nil
        self.onChange(frame)
      }
    }
  }
}

/// SwiftUI Tooltip Modifier，负责悬停状态和显示延迟。
public struct WeekoTooltipModifier: ViewModifier {
  private let text: String
  private let delay: TimeInterval
  private let position: WeekoTooltipPosition
  private let style: WeekoTooltipStyle

  @State private var isHovered = false
  @State private var hoverTask: Task<Void, Never>?
  @State private var anchorBox = WeekoTooltipAnchorBox()
  @State private var owner = UUID()

  /// 创建 Tooltip Modifier。
  public init(
    text: String,
    delay: TimeInterval = 0.3,
    position: WeekoTooltipPosition = .top,
    style: WeekoTooltipStyle = .standard
  ) {
    self.text = text
    self.delay = delay
    self.position = position
    self.style = style
  }

  /// 绑定坐标锚点、悬停延迟和生命周期清理。
  public func body(content: Content) -> some View {
    content
      .overlay {
        WeekoTooltipAnchorView(anchorBox: anchorBox) { rect in
          anchorBox.frame = rect
          guard isHovered else { return }
          WeekoTooltipPresenter.shared.update(anchorRect: rect, owner: owner)
        }
        // 显式占满被修饰 View，避免 NSViewRepresentable 使用零尺寸默认 frame。
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
      }
      .onHover { hovering in
        isHovered = hovering
        hoverTask?.cancel()

        if hovering {
          // 延迟期间不监听窗口移动，显示前只同步读取一次最新坐标。
          anchorBox.setTracking(false)
          hoverTask = Task { @MainActor in
            do {
              try await Task.sleep(nanoseconds: UInt64(max(0, delay) * 1_000_000_000))
            } catch {
              return
            }
            guard !Task.isCancelled,
                  isHovered,
                  let anchorRect = anchorBox.refreshFrame()
            else {
              return
            }
            WeekoTooltipPresenter.shared.show(
              text: text,
              anchorRect: anchorRect,
              position: position,
              style: style,
              owner: owner
            )
            // Tooltip 已显示，窗口移动时才持续刷新其位置。
            anchorBox.setTracking(true)
          }
        } else {
          anchorBox.setTracking(false)
          WeekoTooltipPresenter.shared.hide(owner: owner)
        }
      }
      .onDisappear {
        hoverTask?.cancel()
        anchorBox.setTracking(false)
        anchorBox.frame = nil
        anchorBox.detach()
        WeekoTooltipPresenter.shared.hide(owner: owner)
      }
  }
}

public extension View {
  /// 为任意 SwiftUI View 添加不受父容器裁剪影响的 Tooltip。
  func weekoTooltip(
    _ text: String,
    delay: TimeInterval = 0.3,
    position: WeekoTooltipPosition = .top,
    style: WeekoTooltipStyle = .standard
  ) -> some View {
    modifier(
      WeekoTooltipModifier(
        text: text,
        delay: delay,
        position: position,
        style: style
      )
    )
  }
}
