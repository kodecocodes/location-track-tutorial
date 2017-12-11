import Foundation

enum NetworkError: Error {
    case failedResponse(URLResponse)
}

extension URLResponse {
    fileprivate var isSuccess: Bool {
        guard let response = self as? HTTPURLResponse else { return false }
        return (200...299).contains(response.statusCode)
    }
}

extension URLSession {
    func objectRequest<C: Codable>(
        with request: URLRequest,
        success: @escaping (C) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        dataRequest(
            with: request,
            success: { data in
                do {
                    let object = try data.decode(C.self)
                    success(object)
                } catch {
                    failure(error)
                }
            },
            failure: failure
        )
    }

    func dataRequest(
        with request: URLRequest,
        success: @escaping (Data) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    failure(error)
                    return
                }

                if let response = response, !response.isSuccess {
                    failure(NetworkError.failedResponse(response))
                    return
                }

                let data = data ?? Data()
                success(data)
            }
        }.resume()
    }
}


extension Data {
    fileprivate func decode<D: Decodable>(_ type: D.Type) throws -> D {
        let decoder = JSONDecoder()
        return try decoder.decode(D.self, from: self)
    }
}
