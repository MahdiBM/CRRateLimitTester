import Hummingbird
import HummingbirdFoundation
import AsyncHTTPClient
import struct Foundation.Date

extension HBApplication {
    /// configure your application
    /// add middleware
    /// setup the encoder/decoder
    /// add your routes
    public func configure() throws {
        
        self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(self.eventLoopGroup))
        
        let token = HBEnvironment.shared.get("token")!
        
        router.get("test-rate") { req -> EventLoopFuture<String> in
            let rate: Int
            let url: String
            let request: HTTPClient.Request
            do {
                rate = try req.uri.queryParameters.require("rate", as: Int.self)
                url = try req.uri.queryParameters.require("url")
                request = try HTTPClient.Request(
                    url: url,
                    method: .GET,
                    headers: ["Authorization": "Bearer \(token)"]
                )
            } catch {
                return req.context.eventLoop.makeFailedFuture(error)
            }
            
            let start = Date()
            
            return (0..<rate).map { idx in
                self.httpClient.execute(request: request).flatMapThrowing { res -> Void in
                    if res.status == .tooManyRequests {
                        throw HBHTTPError(.tooManyRequests)
                    } else if res.status != .ok {
                        throw HBHTTPError(res.status)
                    }
                    return
                }
            }.reduce(into: self.eventLoopGroup.next().makeSucceededVoidFuture()) { result, next in
                result = result.flatMap({ next })
            }.map { _ -> String in
                let end = Date()
                let interval = end.timeIntervalSinceReferenceDate
                - start.timeIntervalSinceReferenceDate
                return "Took \(interval) seconds for \(rate) requests."
            }
        }
    }
}

// MARK: - httpClient
extension HBApplication {
    var httpClient: HTTPClient {
        get { self.extensions.get(\.httpClient) }
        set {
            self.extensions.set(\.httpClient, value: newValue, shutdownCallback: { httpClient in
                try httpClient.syncShutdown()
            })
        }
    }
}
