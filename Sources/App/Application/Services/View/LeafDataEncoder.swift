import Leaf
import SwiftyJSON
import Vapor

final class LeafDataEncoder {

    func encode(encodable: Encodable) throws -> [String: LeafData] {
        return try encode(dictionary: encodable.asDictionary())
    }

    func encode(dictionary: [String: JSON]) -> [String: LeafData] {
        var result = [String: LeafData]()
        for (key, value) in dictionary {
            if let intValue = value.object as? Int {
                result[key] = .int(intValue)
            } else if let leafData = value.object as? LeafDataRepresentable {
                result[key] = leafData.leafData
            } else if let array = value.array {
                result[key] = .array(encode(array: array))
            } else if let dictionary = value.dictionary {
                result[key] = .dictionary(encode(dictionary: dictionary))
            }
        }
        return result
    }

    func encode(array: [JSON]) -> [LeafData] {
        var result = [LeafData]()
        for value in array {
            if let intValue = value.object as? Int {
                result.append(.int(intValue))
            } else if let leafData = value.object as? LeafDataRepresentable {
                if let data = leafData.leafData {
                    result.append(data)
                }
            } else if let array = value.array {
                result.append(.array(encode(array: array)))
            } else if let dictionary = value.dictionary {
                result.append(.dictionary(encode(dictionary: dictionary)))
            }
        }
        return result
    }
}

private extension Encodable {
    func asDictionary() throws -> [String: JSON] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        let json = try JSON(data: data)
        return json.dictionaryValue
    }
}
