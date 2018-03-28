/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
