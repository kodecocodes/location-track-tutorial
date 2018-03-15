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

import Vapor
import Foundation

// This is the demo API key, do not use this for production purposes.
// get your own key at https://wordnik.com
private let apiKey = "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
private let wordAPI = "http://api.wordnik.com/v4/words.json/randomWords?hasDictionaryDef=true&minLength=5&maxLength=10&limit=3&api_key=\(apiKey)"

private struct WordResult: Content {
    let id: Int
    let word: String
}

final class KeyGenerator {
    static func randomKey(for request: Request) throws -> Future<String> {
        let client = try request.make(Client.self)
        let uri = URI(stringLiteral: wordAPI)
        let send = client.send(.get, to: uri)
        send.catch { error in
            print(error)
        }
        return send.flatMap(to: [WordResult].self) { response in
                return try [WordResult].decode(from: response, for: request)
            }
            .map(to: String.self) { words in
                words.map { $0.word } .joined(separator: ".") .lowercased()
            }
    }
}
