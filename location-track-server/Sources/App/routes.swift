import Routing
import Vapor
import WebSocket
import Foundation

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyonnd a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
let sessionManager = TrackingSessionManager()

public func routes(_ router: Router) throws {

    // MARK: Status Checks

    router.get("status") { _ in "ok \(Date())" }

    router.websocket("echo-test") { req, ws in
        print("ws connnected")
        ws.onString { ws, string in
            print("ws received: \(string)")
            ws.send(string: "echo - \(string)")
        }
    }

    router.get("wordnik-test") { request in
        return try KeyGenerator.randomKey(for: request)
    }

    // MARK: Poster Routes

    router.post("create", use: sessionManager.createTrackingSession)

    router.post("close", TrackingSession.parameter) { req -> HTTPResponse in
        let session = try req.parameter(TrackingSession.self)
        sessionManager.close(session)
        return HTTPResponse()
    }

    router.post("update", TrackingSession.parameter) { req -> Future<HTTPResponse> in
        let session = try req.parameter(TrackingSession.self)
        return try Location.decode(from: req).map(to: HTTPResponse.self) { location in
            sessionManager.update(location, for: session)
            return HTTPResponse()
        }
    }

    // MARK: Observer Routes

    router.websocket("listen", TrackingSession.parameter) { (req, ws) in
        let session = try req.parameter(TrackingSession.self)
        guard sessionManager.sessions[session] != nil else {
            ws.close()
            return
        }
        sessionManager.add(listener: ws, to: session)
    }
}
