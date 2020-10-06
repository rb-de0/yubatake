import Vapor

struct CSPConfig: Decodable {

    private struct Value: Decodable {
        let key: String
        let values: [String]
    }

    private let values: [Value]

    init(from decoder: Decoder) throws {
        var values = [Value]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let value = try container.decode(Value.self)
            values.append(value)
        }
        self.values = values
    }

    func makeHeader() -> String {
        let space = " "
        let semicolon = ";"
        return values
            .map { ([$0.key, "'self'"] + $0.values).joined(separator: space) }
            .joined(separator: semicolon)
    }
}
