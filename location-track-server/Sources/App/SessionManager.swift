import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class TrackingSessionManager {

    // MARK: Member Variables

    private(set) var sessions: [TrackingSession: [WebSocket]] = [:]

    // MARK: Observer Interactions

    func add(listener: WebSocket, to session: TrackingSession) {
        guard var listeners = sessions[session] else { return }
        listeners.append(listener)
        sessions[session] = listeners

        listener.onClose { [weak self] (ws, buffer) in
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket, from session: TrackingSession) {
        guard var listeners = sessions[session] else { return }
        listeners = listeners.filter { $0 !== listener }
        sessions[session] = listeners
    }

    // MARK: Poster Interactions
    
    func createTrackingSession(for request: Request) throws -> Future<TrackingSession> {
        return wordKey()
            .flatMap(to: TrackingSession.self) { [unowned self] key -> Future<TrackingSession> in
                let session = TrackingSession(id: key)
                guard self.sessions[session] == nil else {
                    return try self.createTrackingSession(for: request)

                }
                self.sessions[session] = []
                return Future(session)
            }
    }

    func update(_ location: Location, for session: TrackingSession) {
        guard let listeners = sessions[session] else { return }
        listeners.forEach { ws in ws.send(location) }
    }

    func close(_ session: TrackingSession) {
        guard let listeners = sessions[session] else { return }
        listeners.forEach { ws in
            ws.close()
        }
        sessions[session] = nil
    }
}
