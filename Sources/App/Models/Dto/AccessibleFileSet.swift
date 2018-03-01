import HTTP

final class AccessibleFileSet: JSONRepresentable {
    
    struct Body: JSONRepresentable {
        
        static let bodyKey = "body"
        static let customizedKey = "customized"
        
        let body: String
        let customized: Bool
        
        func makeJSON() throws -> JSON {
            var json = JSON()
            try json.set(Body.bodyKey, body)
            try json.set(Body.customizedKey, customized)
            return json
        }
    }
    
    static let pathKey = "path"
    static let bodiesKey = "bodies"
    static let themeKey = "theme"
    
    private lazy var fileRepository = resolve(FileRepository.self)
    
    let path: String
    let type: FileType
    let theme: String?
    let bodies: [Body]
    
    init(request: Request) throws {
        
        let fileRepository = resolve(FileRepository.self)
        let path = request.data[AccessibleFileSet.pathKey]?.string
        let type = request.data[AccessibleFile.typeKey]?.string.flatMap { FileType(rawValue: $0) }
        let theme = request.data[AccessibleFileSet.themeKey]?.string
        
        guard let _path = path, let _type = type else {
            throw Abort(.badRequest)
        }
        
        self.path = _path
        self.type = _type
        self.theme = theme
        
        if let _theme = theme {
            let data = try fileRepository.readThemeFileData(in: _theme, at: _path, type: _type)
            self.bodies = [Body(body: data, customized: false)]
            return
        }
        
        var bodies = [Body]()
        
        let originalData = try fileRepository.readFileData(at: _path, type: _type)
        bodies.append(Body(body: originalData, customized: false))
        
        if let userData = try? fileRepository.readUserFileData(at: _path, type: _type) {
            bodies.append(Body(body: userData, customized: true))
        }
        
        self.bodies = bodies.sorted(by: { (lhs, _) in lhs.customized })
    }
    
    func update(body: String) throws {
        
        if theme != nil {
            throw Abort(.forbidden)
        }
        
        try fileRepository.writeUserFileData(at: path, type: type, data: body)
    }
    
    func delete() throws {
        
        if theme != nil {
            throw Abort(.forbidden)
        }
        
        try fileRepository.deleteUserFileData(at: path, type: type)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFileSet.pathKey, path)
        try json.set(AccessibleFile.typeKey, type.rawValue)
        try json.set(AccessibleFileSet.bodiesKey, bodies.makeJSON())
        return json
    }
}

