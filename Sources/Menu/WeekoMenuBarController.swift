import AppKit
import SwiftUI

public enum WeekoMenuBarIcon {
  case systemSymbol(String)
  case image(NSImage)

  fileprivate func makeImage(accessibilityLabel: String) -> NSImage {
    let image: NSImage
    switch self {
    case let .systemSymbol(name):
      image = NSImage(
        systemSymbolName: name,
        accessibilityDescription: accessibilityLabel
      ) ?? NSImage(size: NSSize(width: 18, height: 18))
    case let .image(source):
      image = source.copy() as? NSImage ?? source
    }
    image.size = NSSize(width: 18, height: 18)
    image.isTemplate = true
    return image
  }
}

public struct WeekoMenuDismissAction {
  private let handler: @MainActor () -> Void

  public init() {
    handler = { @MainActor in }
  }

  fileprivate init(handler: @escaping @MainActor () -> Void) {
    self.handler = handler
  }

  @MainActor
  public func callAsFunction() {
    handler()
  }
}

private struct WeekoMenuDismissActionKey: EnvironmentKey {
  static let defaultValue = WeekoMenuDismissAction()
}

public extension EnvironmentValues {
  var weekoMenuDismiss: WeekoMenuDismissAction {
    get { self[WeekoMenuDismissActionKey.self] }
    set { self[WeekoMenuDismissActionKey.self] = newValue }
  }
}

@MainActor
public final class WeekoMenuBarController: NSObject {
  private enum Layout {
    static let screenPadding: CGFloat = 8
    static let menuBarSpacing: CGFloat = 6
    static let transitionOffset: CGFloat = 7
    static let cornerRadius: CGFloat = 15
    static let statusItemSetupDelay: TimeInterval = 0.1
    static let showDuration: TimeInterval = 0.18
    static let hideDuration: TimeInterval = 0.14
    static let dismissCompletionGracePeriod: TimeInterval = 0.12
  }

  private let panelWidth: CGFloat
  private let statusItemLength: CGFloat
  private let statusItemIcon: WeekoMenuBarIcon
  private let statusItemToolTip: String?
  private let statusItemAccessibilityLabel: String
  private let onWillPresent: (@MainActor () -> Void)?
  private let content: () -> AnyView

  private var statusItem: NSStatusItem?
  private var statusItemSetupTask: Task<Void, Never>?
  private var localEventMonitor: Any?
  private var globalEventMonitor: Any?
  private var restingFrame = NSRect.zero
  private var transitionGeneration = 0
  private var isPanelLoaded = false
  private var isDismissing = false
  private var dismissFallbackWorkItem: DispatchWorkItem?
  private var pendingDismissCompletions: [() -> Void] = []

  private lazy var hostingController: NSHostingController<AnyView> = {
    let rootView = AnyView(
      content()
        .environment(
          \.weekoMenuDismiss,
          WeekoMenuDismissAction { [weak self] in
            self?.dismiss()
          }
        )
    )
    let controller = NSHostingController(rootView: rootView)
    controller.sizingOptions = []
    return controller
  }()

  private lazy var panel: NSPanel = {
    let panel = WeekoMenuPanelWindow(
      contentRect: .zero,
      styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = true
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.level = .popUpMenu
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    panel.contentViewController = hostingController
    panel.contentView?.wantsLayer = true
    panel.contentView?.layer?.cornerRadius = Layout.cornerRadius
    panel.contentView?.layer?.masksToBounds = true
    isPanelLoaded = true
    return panel
  }()

  public init<Content: View>(
    panelWidth: CGFloat = 352,
    statusItemLength: CGFloat = NSStatusItem.squareLength,
    statusItemIcon: WeekoMenuBarIcon,
    statusItemToolTip: String? = nil,
    statusItemAccessibilityLabel: String,
    onWillPresent: (@MainActor () -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.panelWidth = max(1, panelWidth)
    self.statusItemLength = statusItemLength
    self.statusItemIcon = statusItemIcon
    self.statusItemToolTip = statusItemToolTip
    self.statusItemAccessibilityLabel = statusItemAccessibilityLabel
    self.onWillPresent = onWillPresent
    self.content = { AnyView(content()) }
    super.init()
  }

  public var isAvailable: Bool {
    statusItem?.button != nil
  }

  public func start(immediately: Bool = false) {
    guard statusItem == nil, statusItemSetupTask == nil else { return }

    if immediately {
      installStatusItem()
      return
    }

    statusItemSetupTask = Task { @MainActor [weak self] in
      do {
        try await Task.sleep(
          nanoseconds: UInt64(Layout.statusItemSetupDelay * 1_000_000_000)
        )
      } catch {
        return
      }

      guard let self, !Task.isCancelled, self.statusItem == nil else { return }
      self.statusItemSetupTask = nil
      self.installStatusItem()
    }
  }

  public func stop() {
    statusItemSetupTask?.cancel()
    statusItemSetupTask = nil
    dismissFallbackWorkItem?.cancel()
    dismissFallbackWorkItem = nil
    removeEventMonitors()
    pendingDismissCompletions.removeAll()
    isDismissing = false

    if isPanelLoaded {
      panel.orderOut(nil)
    }
    if let statusItem {
      NSStatusBar.system.removeStatusItem(statusItem)
      self.statusItem = nil
    }
  }

  public func show() {
    showMenu()
  }

  /// Re-measures and repositions a visible panel after its SwiftUI content changes size.
  public func refreshLayout() {
    guard !isDismissing,
          isPanelLoaded,
          panel.isVisible,
          let button = statusItem?.button,
          let buttonWindow = button.window
    else {
      return
    }

    updatePanelSize(relativeTo: buttonWindow)
    restingFrame = menuFrame(relativeTo: button, in: buttonWindow)
    panel.setFrame(restingFrame, display: true, animate: false)
  }

  public func dismiss(completion: (() -> Void)? = nil) {
    if let completion {
      pendingDismissCompletions.append(completion)
    }

    guard isPanelLoaded, panel.isVisible else {
      runPendingDismissCompletions()
      return
    }
    guard !isDismissing else { return }

    isDismissing = true
    transitionGeneration += 1
    let generation = transitionGeneration
    removeEventMonitors()

    var hiddenFrame = restingFrame
    if !reduceMotion {
      hiddenFrame.origin.y += Layout.transitionOffset
    }
    let fallbackWorkItem = DispatchWorkItem { [weak self] in
      Task { @MainActor [weak self] in
        self?.finishDismissal(for: generation)
      }
    }
    dismissFallbackWorkItem?.cancel()
    dismissFallbackWorkItem = fallbackWorkItem
    DispatchQueue.main.asyncAfter(
      deadline: .now() + Layout.hideDuration + Layout.dismissCompletionGracePeriod,
      execute: fallbackWorkItem
    )

    NSAnimationContext.runAnimationGroup { context in
      context.duration = reduceMotion ? 0 : Layout.hideDuration
      context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      panel.animator().alphaValue = 0
      panel.animator().setFrame(hiddenFrame, display: true)
    } completionHandler: {
      Task { @MainActor [weak self] in
        self?.finishDismissal(for: generation)
      }
    }
  }

  public func updateStatusItem(
    icon: WeekoMenuBarIcon? = nil,
    tint: NSColor? = nil,
    toolTip: String? = nil,
    accessibilityLabel: String? = nil
  ) {
    guard let button = statusItem?.button else { return }
    if let icon {
      button.image = icon.makeImage(
        accessibilityLabel: accessibilityLabel ?? statusItemAccessibilityLabel
      )
      button.imagePosition = .imageOnly
    }
    button.contentTintColor = tint
    if let toolTip {
      button.toolTip = toolTip
    }
    if let accessibilityLabel {
      button.setAccessibilityLabel(accessibilityLabel)
    }
  }

  @objc private func toggleMenu() {
    if isDismissing || !isPanelLoaded || !panel.isVisible {
      showMenu()
    } else {
      dismiss()
    }
  }

  private func installStatusItem() {
    guard statusItem == nil else { return }
    let item = NSStatusBar.system.statusItem(withLength: statusItemLength)
    statusItem = item
    configureStatusItem(item)
  }

  private func configureStatusItem(_ item: NSStatusItem) {
    guard let button = item.button else { return }
    button.image = statusItemIcon.makeImage(accessibilityLabel: statusItemAccessibilityLabel)
    button.imagePosition = .imageOnly
    button.toolTip = statusItemToolTip
    button.setAccessibilityLabel(statusItemAccessibilityLabel)
    button.target = self
    button.action = #selector(toggleMenu)
    button.sendAction(on: [.leftMouseUp, .rightMouseUp])
  }

  private func showMenu() {
    guard let button = statusItem?.button, let buttonWindow = button.window else { return }

    dismissFallbackWorkItem?.cancel()
    dismissFallbackWorkItem = nil
    transitionGeneration += 1
    isDismissing = false
    panel.animations = [:]
    panel.contentView?.layer?.removeAllAnimations()
    panel.alphaValue = 1
    runPendingDismissCompletions()

    onWillPresent?()
    updatePanelSize(relativeTo: buttonWindow)
    restingFrame = menuFrame(relativeTo: button, in: buttonWindow)

    var initialFrame = restingFrame
    if !reduceMotion {
      initialFrame.origin.y += Layout.transitionOffset
    }
    panel.setFrame(initialFrame, display: false)
    panel.alphaValue = reduceMotion ? 1 : 0
    panel.makeKeyAndOrderFront(nil)
    installEventMonitors()

    let generation = transitionGeneration
    NSAnimationContext.runAnimationGroup { context in
      context.duration = reduceMotion ? 0 : Layout.showDuration
      context.timingFunction = CAMediaTimingFunction(name: .easeOut)
      panel.animator().alphaValue = 1
      panel.animator().setFrame(restingFrame, display: true)
    } completionHandler: { [weak self] in
      Task { @MainActor [weak self] in
        guard let self, self.transitionGeneration == generation else { return }
        self.panel.alphaValue = 1
        self.panel.setFrame(self.restingFrame, display: false)
      }
    }
  }

  private func updatePanelSize(relativeTo window: NSWindow) {
    let visibleHeight = window.screen?.visibleFrame.height ?? NSScreen.main?.visibleFrame.height ?? 900
    let maximumHeight = max(1, visibleHeight - Layout.screenPadding * 2)
    let proposedSize = hostingController.sizeThatFits(
      in: NSSize(width: panelWidth, height: maximumHeight)
    )
    guard proposedSize.height.isFinite, proposedSize.height > 1 else { return }
    panel.setContentSize(
      NSSize(width: panelWidth, height: min(ceil(proposedSize.height), maximumHeight))
    )
  }

  private var reduceMotion: Bool {
    NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
  }

  private func menuFrame(relativeTo button: NSStatusBarButton, in window: NSWindow) -> NSRect {
    let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
    let screenFrame = (window.screen ?? NSScreen.main)?.visibleFrame ?? .zero
    let panelSize = panel.frame.size
    let proposedX = buttonFrame.midX - panelSize.width / 2
    let minimumX = screenFrame.minX + Layout.screenPadding
    let maximumX = screenFrame.maxX - panelSize.width - Layout.screenPadding
    let originX = min(max(proposedX, minimumX), maximumX)
    let proposedY = buttonFrame.minY - panelSize.height - Layout.menuBarSpacing
    let minimumY = screenFrame.minY + Layout.screenPadding
    let maximumY = screenFrame.maxY - panelSize.height - Layout.screenPadding
    let originY = min(max(proposedY, minimumY), maximumY)
    return NSRect(origin: NSPoint(x: originX, y: originY), size: panelSize)
  }

  private func installEventMonitors() {
    removeEventMonitors()

    localEventMonitor = NSEvent.addLocalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown, .keyDown]
    ) { [weak self] event in
      guard let self else { return event }
      if event.type == .keyDown, event.keyCode == 53 {
        dismiss()
        return nil
      }
      if event.type != .keyDown,
        !isPointerOverStatusItem,
        !isPointerOverMenuPanel,
        event.window !== panel
      {
        dismiss()
      }
      return event
    }

    globalEventMonitor = NSEvent.addGlobalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown]
    ) { [weak self] event in
      Task { @MainActor [weak self] in
        guard let self,
          !self.isPointerOverStatusItem,
          !self.isEventInsideMenuPanel(event)
        else {
          return
        }
        self.dismiss()
      }
    }
  }

  private func removeEventMonitors() {
    if let localEventMonitor {
      NSEvent.removeMonitor(localEventMonitor)
      self.localEventMonitor = nil
    }
    if let globalEventMonitor {
      NSEvent.removeMonitor(globalEventMonitor)
      self.globalEventMonitor = nil
    }
  }

  private var isPointerOverStatusItem: Bool {
    guard let button = statusItem?.button, let window = button.window else { return false }
    return window.convertToScreen(button.convert(button.bounds, to: nil)).contains(NSEvent.mouseLocation)
  }

  private var isPointerOverMenuPanel: Bool {
    isPanelLoaded && panel.frame.contains(NSEvent.mouseLocation)
  }

  private func isEventInsideMenuPanel(_ event: NSEvent) -> Bool {
    guard isPanelLoaded else { return false }
    return event.windowNumber == panel.windowNumber || isPointerOverMenuPanel
  }

  private func finishDismissal(for generation: Int) {
    guard transitionGeneration == generation, isDismissing else { return }
    dismissFallbackWorkItem?.cancel()
    dismissFallbackWorkItem = nil
    panel.orderOut(nil)
    panel.alphaValue = 1
    panel.setFrame(restingFrame, display: false)
    isDismissing = false
    runPendingDismissCompletions()
  }

  private func runPendingDismissCompletions() {
    let completions = pendingDismissCompletions
    pendingDismissCompletions.removeAll()
    completions.forEach { $0() }
  }
}

private final class WeekoMenuPanelWindow: NSPanel {
  override var canBecomeKey: Bool { true }
}
