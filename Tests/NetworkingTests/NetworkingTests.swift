import XCTest
@testable import Networking

private struct TestEndpoint: Endpoint {
    var path: String {
        "/launches"
    }
}

private struct EmptyEndpoint: Endpoint {}

private struct InvalidEndpoint: Endpoint {
    var path: String { ":-80" }
}

private struct FilledEndpoint: Endpoint {
    let method: HTTPMethod

    var path: String {
        "/path"
    }

    var queries: [String: String] {
        ["query": "param"]
    }

    var headers: [String: String] {
        ["header": "value"]
    }

    var body: Encodable? {
        Launch(id: "id")
    }

    init(method: HTTPMethod) {
        self.method = method
    }
}

private struct Launch: Codable {
    let id: String
}

private enum TestError: Error {
    case dummy
}

final class NetworkingTests: XCTestCase {
    private let defaultProvider: EndpointProvider = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return EndpointProvider(
            networking: URLSessionNetworking(session: .shared),
            decoder: decoder,
            encoder: JSONEncoder(),
            baseURL: "https://api.spacexdata.com/v5",
            headers: [:]
        )
    }()

    func testURLSessionNetworking() async throws {
        let networking = URLSessionNetworking(session: .shared)
        guard let url = URL(string: "https://google.com") else {
            XCTAssert(true)
            return
        }
        let response = try await networking.request(request: .init(url: url))
        XCTAssertNotNil(response.0)
        XCTAssertNotNil(response.1)
    }

    func testEndpointProvider() async throws {
        let response: [Launch] = try await defaultProvider.sendRequest(to: TestEndpoint())
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isEmpty)
    }

    func testErrorNetworking() async throws {
        let networking = ErrorNetworking(error: TestError.dummy)
        do {
            guard let url = URL(string: "https://api.spacexdata.com/v5/launches") else {
                XCTAssert(true)
                return
            }
            try await _ = networking.request(request: .init(url: url))
            XCTAssert(true)
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testEmptyEndpoint() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let provider = EndpointProvider(
            networking: URLSessionNetworking(session: .shared),
            decoder: decoder,
            encoder: JSONEncoder(),
            baseURL: "https://api.spacexdata.com/v5/launches",
            headers: [:]
        )
        let response: [Launch] = try await provider.sendRequest(to: EmptyEndpoint())
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isEmpty)
    }

    func testErrorResponse() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let provider = EndpointProvider(
            networking: URLSessionNetworking(session: .shared),
            decoder: decoder,
            encoder: JSONEncoder(),
            baseURL: "https://hopefullynotexistingwebsite.com",
            headers: [:]
        )
        do {
            try await _ = provider.sendRequest(to: EmptyEndpoint()) as String
            XCTAssert(true)
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testInvalidBaseURL() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let provider = EndpointProvider(
            networking: URLSessionNetworking(session: .shared),
            decoder: decoder,
            encoder: JSONEncoder(),
            baseURL: "http://malformed:-1/",
            headers: [:]
        )
        do {
            try await _ = provider.sendRequest(to: EmptyEndpoint()) as String
            XCTAssert(true)
        } catch {
            XCTAssertEqual(error as? NetworkingError, .invalidBaseURL)
        }
    }

    func testBuildingEndpoints() async throws {
        let encoder = JSONEncoder()
        let baseURL = "https://google.com"
        let headers = ["globalHeader": "value", "header": "overrideValue"]
        let endpoints = HTTPMethod.allCases.map { FilledEndpoint(method: $0) }
        let requests = endpoints.compactMap {
            try? $0.buildURLRequest(
                encoder: encoder,
                baseURL: baseURL,
                headers: headers
            )
        }
        XCTAssertEqual(endpoints.count, requests.count)
        for (endpoint, request) in zip(endpoints, requests) {
            let url = baseURL + endpoint.path + endpoint.queries.flatMap { "?\($0)=\($1)" }
            XCTAssertEqual(request.url?.absoluteString, url)
            XCTAssertEqual(request.httpMethod, endpoint.method.rawValue)
            XCTAssertEqual(request.allHTTPHeaderFields, ["header": "value", "globalHeader": "value"])
            XCTAssertEqual(request.httpBody, try? encoder.encode(Launch(id: "id")))
        }
    }

    func testInvalidEndpoint() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let provider = EndpointProvider(
            networking: URLSessionNetworking(session: .shared),
            decoder: decoder,
            encoder: JSONEncoder(),
            baseURL: "https://google.com",
            headers: [:]
        )
        do {
            _ = try await provider.sendRequest(to: InvalidEndpoint()) as String
            XCTAssert(true)
        } catch {
            XCTAssertEqual(error as? NetworkingError, .invalidEndpoint)
        }
    }
}
