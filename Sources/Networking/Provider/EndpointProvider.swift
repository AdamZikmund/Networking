import Foundation

public class EndpointProvider: NetworkingProvider {
    // MARK: - Properties
    private let networking: Networking
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let baseURL: String
    private let headers: [String: String]

    // MARK: - Lifecycle
    /// Creates new instance of endpoint provider
    /// - Parameters:
    ///   - networking: Instance of networking protocol
    ///   - decoder: JSON Decoder used for decoding
    ///   - encoder: JSON Encoder used for encoding
    ///   - baseURL: Base url for all endpoint calls
    ///   - headers: Additional headers for all endpoint calls
    public init(
        networking: Networking,
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        baseURL: String,
        headers: [String : String]
    ) {
        self.networking = networking
        self.decoder = decoder
        self.encoder = encoder
        self.baseURL = baseURL
        self.headers = headers
    }
}

// MARK: - Provider
public extension EndpointProvider {
    /// Sends asynchronous request built from endpoint model
    /// - Parameter endpoint: Endpoint model
    /// - Returns: Decoded model
    func sendRequest<T>(
        to endpoint: Endpoint
    ) async throws -> T where T : Decodable {
        let request = try endpoint.buildURLRequest(
            encoder: encoder,
            baseURL: baseURL,
            headers: headers
        )
        let (data, _) = try await networking.request(request: request)
        return try decoder.decode(T.self, from: data)
    }
}
