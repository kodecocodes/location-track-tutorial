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
        return client.send(.get, to: uri)
            .then { response in
                return try [WordResult].decode(from: response, for: request)
            }
            .map { words in
                words.map { $0.word } .joined(separator: ".") .lowercased()
            }
    }
}
