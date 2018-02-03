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
    
    let path: String
    let type: FileType
    let bodies: [Body]
    
    init(request: Request) throws {
        
        let path = request.data[AccessibleFileSet.pathKey]?.string
        let type = request.data[AccessibleFile.typeKey]?.string.flatMap { FileType(rawValue: $0) }
        
        guard let _path = path, let _type = type else {
            throw Abort(.badRequest)
        }
        
        self.path = _path
        self.type = _type
        
        let targetFile = FileHelper.accessibleFiles()
            .flatMap { $0.files }
            .first(where: {  $0.relativePath == _path && $0.type == _type })
        
        guard let _targetFile = targetFile else {
            self.bodies = []
            return
        }
        
        var bodies = [Body]()
        
        if let originalFilePath = _targetFile.originalPathToRoot {
            let originalData = try FileHelper.readFileData(at: originalFilePath, type: _type)
            bodies.append(Body(body: originalData, customized: false))
        }
        
        if let userFilePath = _targetFile.userPathToRoot {
            let userData = try FileHelper.readFileData(at: userFilePath, type: _type)
            bodies.append(Body(body: userData, customized: true))
        }
        
        self.bodies = bodies.sorted(by: { (lhs, _) in lhs.customized })
    }
    
    func update(body: String) throws {
        try FileHelper.writeUserFileData(at: path, type: type, data: body)
    }
    
    func delete() throws {
        try FileHelper.deleteUserFileData(at: path, type: type)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(AccessibleFileSet.pathKey, path)
        try json.set(AccessibleFile.typeKey, type.rawValue)
        try json.set(AccessibleFileSet.bodiesKey, bodies.makeJSON())
        return json
    }
}

