
struct ContextWrapper<T: Encodable, U: Encodable>: Encodable {
    
    let source: T
    let properties: [String: U]
    
    func encode(to encoder: Encoder) throws {
        try source.encode(to: encoder)
        try properties.encode(to: encoder)
    }
}

extension Encodable {
    
    func add<U: Encodable>(_ key: String, _ value: U) -> ContextWrapper<Self, U> {
        return ContextWrapper<Self, U>(source: self, properties: [key: value])
    }
}
