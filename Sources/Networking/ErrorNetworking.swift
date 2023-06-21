import Foundation

public class ErrorNetworking: Networking {
    // MARK: - Properties
    private let error: Error

    // MARK: - Lifecycle
    public init(error: Error) {
        self.error = error
    }
}

// MARK: - Networking
public extension ErrorNetworking {
    func request(request: URLRequest) async throws -> (Data, URLResponse) {
        throw error
    }
}
