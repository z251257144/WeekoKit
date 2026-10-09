import AppKit
import SwiftUI

private final class DemoBorderlessWindow: NSWindow {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}

@MainActor
private extension NSWindow {
  func bringDemoToFront() {
    if NSApplication.shared.isHidden {
      NSApplication.shared.unhide(nil)
    }
    orderFrontRegardless()
    NSApplication.shared.activate(ignoringOtherApps: true)
    makeKey()
  }
}

@MainActor
final class DemoSettingsWindowController: NSWindowController {
  static let shared = DemoSettingsWindowController()

  private static let windowSize = CGSize(width: 940, height: 720)

  private init() {
    let window = DemoBorderlessWindow(
      contentRect: NSRect(origin: .zero, size: Self.windowSize),
      styleMask: [.borderless, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    window.backgroundColor = .clear
    window.isOpaque = false
    window.isReleasedWhenClosed = false
    window.hasShadow = true
    window.isMovableByWindowBackground = true
    window.contentViewController = NSHostingController(
      rootView: ContentView(permissionStore: .shared, navigation: .shared)
    )

    super.init(window: window)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  func show(page: DemoPage? = nil) {
    if let page {
      DemoSettingsNavigation.shared.selection = page
    }

    guard let window else { return }
    if !window.isVisible {
      window.center()
    }
    window.bringDemoToFront()
  }

  func hide() {
    window?.orderOut(nil)
  }
}

@MainActor
final class DemoPermissionWindowController: NSWindowController {
  static let screenRecording = DemoPermissionWindowController(kind: .screenRecording)
  static let microphone = DemoPermissionWindowController(kind: .microphone)
  static let notifications = DemoPermissionWindowController(kind: .notifications)

  private static let windowSize = CGSize(width: 600, height: 500)
  private let kind: DemoPermissionKind

  private init(kind: DemoPermissionKind) {
    self.kind = kind
    super.init(window: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError()
  }

  static func controller(for kind: DemoPermissionKind) -> DemoPermissionWindowController {
    switch kind {
    case .screenRecording:
      screenRecording
    case .microphone:
      microphone
    case .notifications:
      notifications
    }
  }

  func show() {
    if window == nil {
      let newWindow = makeWindow()
      self.window = newWindow
      newWindow.center()
    }

    guard let window else { return }
    window.bringDemoToFront()
  }

  func hide() {
    window?.orderOut(nil)
  }

  private func makeWindow() -> NSWindow {
    let window = DemoBorderlessWindow(
      contentRect: NSRect(origin: .zero, size: Self.windowSize),
      styleMask: [.borderless, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    window.backgroundColor = .clear
    window.isOpaque = false
    window.isReleasedWhenClosed = false
    window.hasShadow = true
    window.isMovableByWindowBackground = true
    window.contentViewController = NSHostingController(
      rootView: DemoPermissionPromptWindow(
        kind: kind,
        permissionStore: .shared,
        onDismiss: { [weak self] in
          self?.hide()
        }
      )
    )
    window.setContentSize(Self.windowSize)
    window.minSize = Self.windowSize
    window.maxSize = Self.windowSize
    return window
  }
}

struct DemoWindowConfigurator: NSViewRepresentable {
  func makeNSView(context _: Context) -> NSView {
    DemoWindowConfigurationView()
  }

  func updateNSView(_: NSView, context _: Context) {}
}

private final class DemoWindowConfigurationView: NSView {
  private weak var configuredWindow: NSWindow?

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    guard let window, configuredWindow !== window else { return }
    configuredWindow = window
    configure(window)
  }

  private func configure(_ window: NSWindow) {
    window.styleMask.insert(.fullSizeContentView)
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.isMovableByWindowBackground = true
    window.isOpaque = false
    window.backgroundColor = .clear

    for buttonType in [
      NSWindow.ButtonType.closeButton,
      .miniaturizeButton,
      .zoomButton,
    ] {
      window.standardWindowButton(buttonType)?.isHidden = true
    }
  }
}
