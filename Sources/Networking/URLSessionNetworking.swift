import Foundation

public class URLSessionNetworking: Networking {
    // MARK: - Properties
    public weak var delegate: URLSessionNetworkingDelegate?
    private let session: URLSession

    // MARK: - Lifecycle
    /// Initialzies new networking based on URLSession
    /// - Parameters:
    ///   - session: Injected URLSession
    ///   - delegate: URLSession networking delegate
    public init(
        session: URLSession,
        delegate: URLSessionNetworkingDelegate? = nil
    ) {
        self.session = session
        self.delegate = delegate
    }
}

// MARK: - Networking
public extension URLSessionNetworking {
    /// Creates asynchronous request
    /// - Parameter request: URLRequest
    /// - Returns: Tuple with data and response
    func request(request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: NetworkingError.missingReference)
                return
            }
            let uuid = UUID()
            let task = self.session.dataTask(with: request) { [weak self] data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    if let self {
                        self.delegate?.networking(
                            self,
                            didReceiveError: error,
                            withUUID: uuid
                        )
                    }
                } else if let data, let response {
                    continuation.resume(returning: (data, response))
                    if let self {
                        self.delegate?.networking(
                            self,
                            didReceiveData: data,
                            withResponse: response,
                            andUUID: uuid
                        )
                    }
                } else {
                    continuation.resume(throwing: NetworkingError.invalidResponse)
                    if let self {
                        self.delegate?.networking(
                            self,
                            didReceiveError: NetworkingError.invalidResponse,
                            withUUID: uuid
                        )
                    }
                }
            }
            task.resume()
            delegate?.networking(self, didSendRequest: request, withUUID: uuid)
        }
    }
}
