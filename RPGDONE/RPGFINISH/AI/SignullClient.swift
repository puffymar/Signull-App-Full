import Foundation
import Network

final class SignullClient {
    static let shared = SignullClient()
    
    private init() {}
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await URLSession.shared.data(for: request)
    }
}
