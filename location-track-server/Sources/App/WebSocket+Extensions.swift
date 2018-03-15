import Vapor
import WebSocket
import Foundation

extension WebSocket {
    func send(_ location: Location) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(location) else { return }
        send(data: data)
    }
}

