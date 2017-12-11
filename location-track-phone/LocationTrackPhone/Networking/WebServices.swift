import Foundation

let host = "localhost:8080"

final class WebServices {
    static let baseURL = "http://\(host)/"

    static let createURL = URL(string: baseURL + "create/")!
    static let updateURL = URL(string: baseURL + "update/")!
    static let closeURL = URL(string: baseURL + "close/")!

    static func create(
        success: @escaping (TrackingSession) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        var request = URLRequest(url: createURL)
        request.httpMethod = "POST"
        URLSession.shared.objectRequest(with: request, success: success, failure: failure)
    }

    static func update(
        _ location: Location,
        for session: TrackingSession,
        completion: @escaping (Bool) -> Void
    ) {
        let url = updateURL.appendingPathComponent(session.id)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            try request.addJSONBody(location)
        } catch {
            completion(false)
            return
        }

        URLSession.shared.dataRequest(
            with: request,
            success: { _ in completion(true) },
            failure: { _ in completion(false) }
        )
    }

    static func close(
        _ session: TrackingSession,
        completion: @escaping (Bool) -> Void
    ) {
        let url = closeURL.appendingPathComponent(session.id)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataRequest(
            with: request,
            success: { _ in completion(true) },
            failure: { _ in completion(false) }
        )
    }
}

extension URLRequest {
    mutating func addJSONBody<C: Codable>(_ object: C) throws {
        let encoder = JSONEncoder()
        httpBody = try encoder.encode(object)
        setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

