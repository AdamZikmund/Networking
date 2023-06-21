import SwiftUI
import Networking

private struct User: Codable {
    let username: String
}

private struct UsersEndpoint: Endpoint {
    var path: String { "/users" }
}

struct ContentView: View {
    private let provider = EndpointProvider(
        networking: URLSessionNetworking(session: .shared),
        decoder: JSONDecoder(),
        encoder: JSONEncoder(),
        baseURL: "https://random-data-api.com/api/v2",
        headers: [:]
    )

    @State private var text = ""

    var body: some View {
        VStack {
            Text(text)
            Button("Send request") {
                Task {
                    do {
                        text = try await doRequest().username
                    } catch {
                        debugPrint(error)
                    }
                }
            }
        }
        .padding()
    }

    private func doRequest() async throws -> User {
        try await provider.sendRequest(to: UsersEndpoint())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
