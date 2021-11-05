//
//  Helper.swift
//  pay
//
//  Created by moumen isawe on 26/09/2021.
//

import Foundation
 
protocol CodableInitializable: Codable {
    init?(data: Data)
    init?(dictionary: [AnyHashable: Any?])
    init?(fromURL url: URL)
}

extension CodableInitializable where Self: Decodable {
    init?(data: Data) {
        do {
            self = try newJSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }
    
    init?(dictionary: [AnyHashable: Any?]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            guard let me = try? newJSONDecoder().decode(Self.self, from: jsonData) else { return nil }
            self = me
        } catch {
            return nil
        }
    }
    
    init?(fromURL url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }
}

extension Array: CodableInitializable where Element: CodableInitializable {}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? newJSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    return encoder
}

protocol CaseIterableDefaultsValue: Decodable & RawRepresentable
where Self.RawValue: Decodable {
    static var defaultValue: Self { get }
}

extension CaseIterableDefaultsValue {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.defaultValue
    }
}
