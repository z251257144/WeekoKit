import AppKit
import SwiftUI

public extension View {
  func weekoPermissionPrompt(
    isPresented: Binding<Bool>,
    coordinator: WeekoPermissionCoordinator,
    kind: WeekoPermissionKind,
    applicationName: String? = nil,
    applicationIcon: NSImage? = nil,
    onEvent: @escaping (WeekoPermissionPromptEvent) -> Void = { _ in }
  ) -> some View {
    weekoPermissionPrompt(
      isPresented: isPresented,
      coordinator: coordinator,
      configuration: WeekoPermissionPromptConfiguration(
        applicationName: applicationName,
        kind: kind
      ),
      applicationIcon: applicationIcon,
      onEvent: onEvent
    )
  }

  func weekoPermissionPrompt(
    isPresented: Binding<Bool>,
    coordinator: WeekoPermissionCoordinator,
    configuration: WeekoPermissionPromptConfiguration,
    applicationIcon: NSImage? = nil,
    onEvent: @escaping (WeekoPermissionPromptEvent) -> Void = { _ in }
  ) -> some View {
    sheet(isPresented: isPresented) {
      WeekoPermissionPromptPage(
        coordinator: coordinator,
        configuration: configuration,
        applicationIcon: applicationIcon,
        onDismiss: { isPresented.wrappedValue = false },
        onEvent: onEvent
      )
      .frame(width: 620, height: 580)
    }
  }
}
