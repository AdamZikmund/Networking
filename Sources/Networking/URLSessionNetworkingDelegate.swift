import Foundation

public protocol URLSessionNetworkingDelegate: AnyObject {
    /// Delegate method called when request was sent
    /// - Parameters:
    ///   - networking: Producer of event
    ///   - request: Sent request
    ///   - uuid: UUID of request for better tracking
    func networking(
        _ networking: Networking,
        didSendRequest request: URLRequest,
        withUUID uuid: UUID
    )

    /// Delegate method called when response was successfully received
    /// - Parameters:
    ///   - networking: Producer of event
    ///   - data: Data in response body
    ///   - response: Response itself
    ///   - uuid: UUID of request for better tracking
    func networking(
        _ networking: Networking,
        didReceiveData data: Data,
        withResponse response: URLResponse,
        andUUID uuid: UUID
    )

    /// Delegate method called when response failed with error
    /// - Parameters:
    ///   - networking: Producer of event
    ///   - error: Received error
    ///   - uuid: UUID of request for better tracking
    func networking(
        _ networking: Networking,
        didReceiveError error: Error,
        withUUID uuid: UUID
    )
}
