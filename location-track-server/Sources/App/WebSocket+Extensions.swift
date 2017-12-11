import Vapor
import WebSocket
import Foundation

extension WebSocket {
    func send<C: Content>(_ content: C) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(content) else { return }
        send(data)
    }
}
