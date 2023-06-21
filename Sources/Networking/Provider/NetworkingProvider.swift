import Foundation

public protocol NetworkingProvider {
    func sendRequest<T: Decodable>(to endpoint: Endpoint) async throws -> T
}
