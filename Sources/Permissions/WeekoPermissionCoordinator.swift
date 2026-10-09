import Combine
import Foundation

@MainActor
public final class WeekoPermissionCoordinator: ObservableObject {
  @Published public private(set) var status: WeekoPermissionStatus
  @Published public private(set) var isRequesting = false

  private let provider: any WeekoPermissionProviding
  private var operationGeneration: UInt64 = 0

  public init(provider: any WeekoPermissionProviding) {
    self.provider = provider
    status = provider.status
  }

  public var hasPermission: Bool {
    status.isAuthorized
  }

  public var didDenyPermission: Bool {
    status.requiresSystemSettings
  }

  @discardableResult
  public func refresh() async -> WeekoPermissionStatus {
    let generation = beginOperation()
    let nextStatus = await provider.refresh()
    guard !Task.isCancelled, generation == operationGeneration else {
      return status
    }
    status = nextStatus
    return nextStatus
  }

  @discardableResult
  public func request() async -> WeekoPermissionStatus {
    guard !isRequesting else { return status }

    isRequesting = true
    let generation = beginOperation()
    defer { isRequesting = false }

    let nextStatus = await provider.request()
    guard !Task.isCancelled, generation == operationGeneration else {
      return status
    }
    status = nextStatus
    return nextStatus
  }

  @discardableResult
  public func openSystemSettings() -> Bool {
    provider.openSystemSettings()
  }

  private func beginOperation() -> UInt64 {
    operationGeneration &+= 1
    return operationGeneration
  }
}
