import Foundation
import Network
import Combine

// MARK: - Global API Handle
enum API {
    static let client = SignullClient.shared
}

// MARK: - Shared URLSession Client
actor SignullClient {
    static let shared = SignullClient()

    private let session: URLSession

    private init() {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = true
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 90
        cfg.httpMaximumConnectionsPerHost = 1
        cfg.allowsConstrainedNetworkAccess = true
        cfg.allowsExpensiveNetworkAccess = true
        cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
        cfg.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "x-signull-auth": "signull_app_token_2024",
            "Connection": "keep-alive"
        ]
        session = URLSession(configuration: cfg)
    }

    func data(for req: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: req)
    }
}

// MARK: - Reachability Gate
final class NetGate: ObservableObject {
    static let shared = NetGate()

    @Published private(set) var isReachable: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "netgate.monitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { [weak self] in
                self?.isReachable = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}

extension NetGate {
    func waitUntilReachable() async {
        if Task.isCancelled { return }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            DispatchQueue.main.async {
                if self.isReachable {
                    cont.resume()
                    return
                }
                var cancellable: AnyCancellable?
                cancellable = self.$isReachable.sink { ok in
                    if ok {
                        cancellable?.cancel()
                        cont.resume()
                    }
                }
            }
        }
    }
}


