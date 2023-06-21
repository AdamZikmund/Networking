import Foundation

enum NetworkingError: Error {
    case invalidResponse
    case invalidBaseURL
    case invalidEndpoint
    case missingReference
}
