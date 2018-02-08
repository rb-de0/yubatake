import Sessions

protocol FormDataDeliverable {
    static func stash(on session: Session, formData: Node) throws
    static func override(node: inout Node, with formData: [String: Node]) throws
}

extension FormDataDeliverable {
    
    static var formDataKey: String {
        return "form_data"
    }
    
    static func makeKey(prefix: String) -> (String...) -> String {
        return { (values: String...) in
            prefix + "." + values.joined(separator: ".")
        }
    }
    
    static func stash(on session: Session, formData: Node) throws {
        try session.data.set(formDataKey, formData)
    }
}

struct NoDerivery: FormDataDeliverable {
    static func stash(on session: Session, formData: Node) throws {}
    static func override(node: inout Node, with formData: [String : Node]) throws {}
}
