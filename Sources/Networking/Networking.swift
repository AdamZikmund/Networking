import Foundation

public protocol Networking {
    func request(request: URLRequest) async throws -> (Data, URLResponse)
}
