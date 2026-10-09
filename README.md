# WeekoKit

Shared macOS infrastructure and SwiftUI for the Weeko apps. The package supports
macOS 13 and later and intentionally does not own application windows or
product-specific feature policies.

## Package Contents

`WeekoKit` is a single import containing application metadata, feedback URL
construction, permission services, StoreKit commerce, reusable macOS settings
components, and configurable About and permission prompt pages.

## Source Layout

Each feature owns its related implementation and UI components:

- `Sources/AppInfo`: application metadata and feedback URLs.
- `Sources/GeneralSettings`: launch at login and Dock visibility preferences.
- `Sources/Localization`: language selection, localized-string lookup and relaunch support.
- `Sources/Permissions`: screen recording, microphone and notification services,
  shared coordinators, and the permission prompt.
- `Sources/Subscription`: StoreKit state, subscription views and localization.
- `Sources/Settings`: reusable macOS settings shell and controls.
- `Sources/About`: About page configuration and view.

## Local Integration

Add the sibling package to an app project as a local package dependency:

```text
../WeekoKit
```

Then link the `WeekoKit` product and import it where shared functionality is
used.

The app remains responsible for product identifiers, window presentation and
business effects after entitlement changes. The shared pages include localized
defaults; copy, colors and legal URLs can still be overridden.

## Subscription Integration

For an app that only needs the standard subscription page, pass the App Store
product identifiers:

```swift
import WeekoKit

WeekoSubscriptionPage(
  annualProductID: "net.weeko.example.yearly",
  lifetimeProductID: "net.weeko.example.lifetime"
)
```

The page loads App Store names, descriptions, localized prices and subscription
periods. It also starts transaction updates, verifies entitlements, purchases,
restores, caches the last plan and displays Terms and Privacy links.

Pass product-specific highlights explicitly to replace the default highlights:

```swift
let highlights = WeekoSubscriptionHighlightsConfiguration(
  title: "Unlock advanced reporting",
  subtitle: "Get the insights your team needs.",
  historyBadgeTitle: "Annual or lifetime",
  localBadgeTitle: "Secure App Store payment",
  features: [
    WeekoSubscriptionFeature(
      id: "reporting",
      icon: "chart.line.uptrend.xyaxis",
      tint: .blue,
      title: "Advanced reports",
      subtitle: "Understand your work at a glance."
    )
  ]
)

WeekoSubscriptionPage(
  annualProductID: "net.weeko.example.yearly",
  lifetimeProductID: "net.weeko.example.lifetime",
  highlights: highlights
)
```

Apps that gate features should own the same store for their lifetime and pass
it to the reusable sections. This makes it possible to place the subscription
content alongside app-specific settings or feature explanations:

```swift
@StateObject private var subscriptions = WeekoEntitlementStore(
  annualProductID: "net.weeko.example.yearly",
  lifetimeProductID: "net.weeko.example.lifetime"
)

var body: some View {
  let highlights = WeekoSubscriptionHighlightsConfiguration(
    title: "Unlock advanced reporting",
    subtitle: "Get the insights your team needs.",
    historyBadgeTitle: "Annual or lifetime",
    localBadgeTitle: "Secure App Store payment",
    features: []
  )
  let configuration = WeekoSubscriptionViewConfiguration.weekoDefault(
    highlights: highlights
  )

  WeekoSettingsFormPage {
    WeekoSubscriptionHighlightsSection(
      configuration: highlights,
      plan: subscriptions.plan
    )
    WeekoSubscriptionCurrentPlanSection(store: subscriptions)
    WeekoSubscriptionPurchaseSection(
      store: subscriptions,
      configuration: configuration
    )
    WeekoSubscriptionRestoreSection(
      store: subscriptions,
      configuration: configuration
    )
  }
  .task(id: subscriptions.plan) {
    subscriptions.start()
    await subscriptions.refreshProducts(force: false)
  }
}
```

Use `subscriptions.isPro` for feature access. The view starts entitlement and
transaction observation automatically; apps that need entitlement state before
showing settings should also call `subscriptions.start()` from their root app
lifecycle.

`WeekoSubscriptionProductRow` is also public for layouts that need to position
individual products outside the packaged purchase section. Pass `nil` for the
`highlights` or `currentPlan` configuration properties to omit either block
from `WeekoSubscriptionView`.

## Menu Interface

Use the menu surface and button components with an app-owned status-bar panel
or popover. WeekoKit provides presentation only; menu commands, dismissal and
application state remain owned by the host app.

```swift
WeekoMenuPanel {
  WeekoMenuHeader(
    applicationName: "Example",
    subtitle: "Ready to capture"
  ) {
    WeekoMenuStatusButton(title: "Granted", tint: .green) {
      openPermissions()
    }
  }
} content: {
  VStack(spacing: 10) {
    WeekoMenuPrimaryButton(
      title: "Capture Screen",
      icon: "camera.viewfinder",
      shortcut: "⌘1"
    ) {
      captureScreen()
    }

    HStack(spacing: 7) {
      WeekoMenuActionButton(title: "Record", icon: "video.fill", tint: .red) {
        recordVideo()
      }
      WeekoMenuActionButton(title: "Record GIF", icon: "photo.stack.fill", tint: .purple) {
        recordGIF()
      }
    }
  }
} footer: {
  HStack(spacing: 7) {
    WeekoMenuTileButton(title: "Settings", icon: "gearshape", tint: .accentColor) {
      showSettings()
    }
    WeekoMenuTileButton(title: "Quit", icon: "power", tint: .red, role: .destructive) {
      NSApplication.shared.terminate(nil)
    }
  }
}
```

## Permission Prompt

Present the permission guidance in a macOS sheet by attaching the modifier to
an owning view:

```swift
@State private var isPermissionPromptPresented = false

var body: some View {
  Button("Request Screen Recording") {
    isPermissionPromptPresented = true
  }
  .weekoPermissionPrompt(
    isPresented: $isPermissionPromptPresented,
    coordinator: screenCaptureCoordinator,
    kind: .screenRecording
  )
}
```

The default API reads the application name from the main bundle and uses
WeekoKit's bundled copy. Pass `configuration:` when the default copy or
behavior does not fit your application.

For flows that must remain available outside a settings window, use
`WeekoPermissionPromptPage` as the root view of a dedicated `WindowGroup` and
pass its `onDismiss` closure the action that closes that window. The demo's
Permission section uses this standalone-window presentation.

## Application Settings

Use one store for an application's lifetime, then display the packaged settings
page wherever application preferences are presented:

```swift
@StateObject private var settingsStore = WeekoSettingsStore()

var body: some View {
  WeekoSettingsPage(store: settingsStore)
}
```

The page handles launch-at-login registration, Dock icon visibility, and the
selected app language. It shows pending language changes and supports undo or
restarting immediately.

## Localization

`WeekoLocalizationStore` manages a supported language catalog and persists an
app-specific `AppleLanguages` choice. It normalizes regional language codes,
tracks whether the selected language differs from the effective bundle language,
and can cancel a pending change.

```swift
let localizations = WeekoLocalizationStore(
  supportedLanguages: [.english, .simplifiedChinese, .traditionalChinese]
)

let title = "settings_title".weekoLocalized(table: "Localizable")
```

`weekoLocalized` falls back to the English resource when a key is absent from
the active localization. Host applications supply their own `.lproj` resources;
the package localizes its application settings page internally.

## Demo App

Open `WeekoKitDemo/WeekoKitDemo.xcodeproj` and run the `WeekoKitDemo` scheme.
The project references the package through the local `..` path and builds with
a macOS 13 deployment target.

The demo includes the settings shell, shared components, configurable About
page, permission prompt states and the complete subscription page. Permission
requests use an in-memory provider. Commerce uses the shared `Demo.storekit`
configuration, so purchases and restores exercise StoreKit Test without making
real App Store charges.
