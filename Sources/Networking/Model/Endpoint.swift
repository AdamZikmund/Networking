import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queries: [String: String] { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
}

// MARK: - Default implementation
public extension Endpoint {
    var path: String { "" }
    var method: HTTPMethod { .GET }
    var queries: [String: String] { [:] }
    var headers: [String: String] { [:] }
    var body: Encodable? { nil }
}

extension Endpoint {
    /// Builds URLRequest from endpoint model
    /// - Parameters:
    ///   - encoder: JSON Encoder used for encoding endpoint body
    ///   - baseURL: Endpoint base url
    ///   - globalHeaders: Global request headers
    /// - Returns: Built URLRequest
    func buildURLRequest(
        encoder: JSONEncoder,
        baseURL: String,
        headers globalHeaders: [String: String]
    ) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkingError.invalidBaseURL
        }
        components.path += path
        if !queries.isEmpty {
            components.queryItems = queries.map { .init(name: $0, value: $1) }
        }
        guard let url = components.url else {
            throw NetworkingError.invalidEndpoint
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.merging(globalHeaders) { old, _ in
            old
        }
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return request
    }
}
