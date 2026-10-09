import XCTest

@testable import WeekoKit

@MainActor
final class WeekoPermissionCoordinatorTests: XCTestCase {
  func testRequestPublishesProviderResult() async {
    let provider = FakePermissionProvider(
      status: .notDetermined,
      requestResult: .authorized
    )
    let coordinator = WeekoPermissionCoordinator(provider: provider)

    let result = await coordinator.request()

    XCTAssertEqual(result, .authorized)
    XCTAssertEqual(coordinator.status, .authorized)
    XCTAssertTrue(coordinator.hasPermission)
    XCTAssertEqual(provider.requestCount, 1)
  }

  func testDeniedStatusRequiresSystemSettings() async {
    let provider = FakePermissionProvider(
      status: .notDetermined,
      refreshResult: .denied
    )
    let coordinator = WeekoPermissionCoordinator(provider: provider)

    await coordinator.refresh()

    XCTAssertTrue(coordinator.didDenyPermission)
    XCTAssertFalse(coordinator.hasPermission)
    XCTAssertTrue(coordinator.openSystemSettings())
    XCTAssertEqual(provider.openSystemSettingsCount, 1)
  }
}

@MainActor
private final class FakePermissionProvider: WeekoPermissionProviding {
  var status: WeekoPermissionStatus
  var refreshResult: WeekoPermissionStatus
  var requestResult: WeekoPermissionStatus
  var requestCount = 0
  var openSystemSettingsCount = 0

  init(
    status: WeekoPermissionStatus,
    refreshResult: WeekoPermissionStatus? = nil,
    requestResult: WeekoPermissionStatus? = nil
  ) {
    self.status = status
    self.refreshResult = refreshResult ?? status
    self.requestResult = requestResult ?? status
  }

  func refresh() async -> WeekoPermissionStatus {
    status = refreshResult
    return status
  }

  func request() async -> WeekoPermissionStatus {
    requestCount += 1
    status = requestResult
    return status
  }

  func openSystemSettings() -> Bool {
    openSystemSettingsCount += 1
    return true
  }
}
