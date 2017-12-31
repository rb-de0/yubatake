import Leaf

final class Escape: BasicTag {
    
    let name: String = "escape"
    
    func compileBody(stem: Stem, raw: String) throws -> Leaf {
        return try stem.spawnLeaf(raw: raw.htmlEscaped())
    }
    
    func run(arguments: ArgumentList) throws -> Node? {
        return nil
    }
    
    func shouldRender(tagTemplate: TagTemplate, arguments: ArgumentList, value: Node?) -> Bool {
        return true
    }
}
