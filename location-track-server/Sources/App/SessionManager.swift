import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyonnd a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class TrackingSessionManager {
    // TODO: ThreadSafe Locks?
    private(set) var sessions: [TrackingSession: [WebSocket]] = [:]
    
    func add(listener: WebSocket, to session: TrackingSession) {
        guard var listeners = sessions[session] else { return }
        listeners.append(listener)
        sessions[session] = listeners
        
        listener.finally { [weak listener, weak self] in
            guard let listener = listener else { return }
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket, from session: TrackingSession) {
        guard var listeners = sessions[session] else { return }
        listeners = listeners.filter { $0 !== listener }
        sessions[session] = listeners
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
    }
    
    func createTrackingSession(for request: Request) throws -> Future<TrackingSession> {
        return try KeyGenerator.randomKey(for: request).then { [unowned self] key -> Future<TrackingSession> in
            let session = TrackingSession(id: key)
            guard self.sessions[session] == nil else {
                return try self.createTrackingSession(for: request)
                
            }
            self.sessions[session] = []
            return Future(session)
        }
    }
}
