import Foundation

protocol CodableNetworkError: Error {
    static func decode(decoder: JSONDecoder, data: Data) throws -> Self
}

extension CodableNetworkError where Self: Codable {
     static func decode(decoder: JSONDecoder, data: Data) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
}
