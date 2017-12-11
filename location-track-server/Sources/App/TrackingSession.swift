import Vapor

struct TrackingSession: Content {
    let id: String
}

extension TrackingSession: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: TrackingSession, rhs: TrackingSession) -> Bool {
    return lhs.id == rhs.id
}

extension TrackingSession: Parameter {
    /// Reads the raw parameter
   static func make(for parameter: String, using container: Container) throws -> TrackingSession {
        return .init(id: parameter)
    }
}
