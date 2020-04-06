struct EncodableWrapper<U: Encodable>: Encodable {

    let source: Encodable
    let properties: [String: U]

    func encode(to encoder: Encoder) throws {
        try source.encode(to: encoder)
        try properties.encode(to: encoder)
    }
}

extension Encodable {
    func add<U: Encodable>(_ key: String, _ value: U) -> EncodableWrapper<U> {
        return EncodableWrapper<U>(source: self, properties: [key: value])
    }
}
