import Combine
import Foundation
import SwiftUI
import WeekoKit

enum DemoText {
  static func localized(_ key: String) -> String {
    WeekoLocalization.string(key, table: "WeekoDemo", bundle: .main)
  }
}

enum DemoPage: String, CaseIterable, Identifiable {
  case components
  case tooltip
  case application
  case permission
  case commerce
  case about

  var id: String { rawValue }
}

@MainActor
final class DemoSettingsNavigation: ObservableObject {
  static let shared = DemoSettingsNavigation()

  @Published var selection: DemoPage = .components
}

@MainActor
final class DemoPermissionStore: ObservableObject {
  static let shared = DemoPermissionStore()

  private let screenRecordingService = WeekoScreenCapturePermissionService()
  private let microphoneService = WeekoMicrophonePermissionService()
  private let notificationService = WeekoNotificationPermissionService()

  let screenRecordingCoordinator: WeekoPermissionCoordinator
  let microphoneCoordinator: WeekoPermissionCoordinator
  let notificationCoordinator: WeekoPermissionCoordinator

  init() {
    screenRecordingCoordinator = WeekoPermissionCoordinator(provider: screenRecordingService)
    microphoneCoordinator = WeekoPermissionCoordinator(provider: microphoneService)
    notificationCoordinator = WeekoPermissionCoordinator(provider: notificationService)
  }
}
