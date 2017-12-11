import Routing
import Vapor
import WebSocket
import Foundation

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyonnd a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
let sessionManager = TrackingSessionManager()

final class Routes: RouteCollection {
    /// Use this to create any services you may
    /// need for your routes.
    let app: Application

    /// Create a new Routes collection with
    /// the supplied application.
    init(app: Application) {
        self.app = app
    }

    /// See RouteCollection.boot
    func boot(router: Router) throws {
        router.get("status") { _ in "ok \(Date())" }

        router.post("create", use: sessionManager.createTrackingSession)
        
        router.post("close", TrackingSession.parameter) { req -> HTTPResponse in
            let session = try req.parameter(TrackingSession.self)
            sessionManager.close(session)
            return HTTPResponse()
        }
        
        router.post("update", TrackingSession.parameter) { req -> Future<HTTPResponse> in
            let session = try req.parameter(TrackingSession.self)
            return try Location.decode(from: req).map { location -> HTTPResponse in
                print(location)
                sessionManager.update(location, for: session)
                return HTTPResponse()
            }
        }

        router.websocket("listen", TrackingSession.parameter) { (req, ws) in
            let session = try req.parameter(TrackingSession.self)
            guard sessionManager.sessions[session] != nil else {
                ws.close()
                return
            }
            sessionManager.add(listener: ws, to: session)
        }
    }
    
}
