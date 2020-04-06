import Foundation
import Leaf

struct CountTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let array = ctx.parameters.first?.array else {
            throw "unable to count unexpected data"
        }
        return .int(array.count)
    }
}

struct DateTag: LeafTag {

    private static let decodeFormatter = ISO8601DateFormatter()

    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let dateString = ctx.parameters.first?.string, let format = ctx.parameters.last?.string else {
            throw "unable to date unexpected data"
        }
        guard let date = Self.decodeFormatter.date(from: dateString) else {
            throw "invalid date format"
        }
        let encodeFormatter = DateFormatter()
        encodeFormatter.dateFormat = format
        return .string(encodeFormatter.string(from: date))
    }
}
