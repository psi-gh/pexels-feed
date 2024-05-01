import Foundation

class DefaultBackendControllerBuilder: BackendControllerBuilderProtocol {
    func buildDefaultBackendController() -> BackendController {
        return DefaultBackendController(networkWorker: NetworkWorker(), credentialStorage: DefaultCredentialStorage.shared)
    }
}
