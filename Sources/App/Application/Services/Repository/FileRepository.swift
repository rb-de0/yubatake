import Vapor

protocol FileRepository {
    
    func allThemes() throws -> [String]
    func isExistTheme(name: String) -> Bool
    
    func files(in theme: Theme) throws -> [EditableFileGroup]
    func readFileBody(using fileio: FileIO, path: String) -> Future<EditableFileBody>
    func writeFileBody(path: String, body: String) throws
}

final class FileRepositoryDefault: FileRepository, Service {
    
    struct Extension {
        static let script = "js"
        static let style = "css"
        static let template = "leaf"
    }
    
    private let fm = FileManager.default
    private let themeDir: String
    
    init(fileConfig: FileConfig) {
        themeDir = fileConfig.themeDir
    }
    
    func allThemes() throws -> [String] {
        
        return try fm.contentsOfDirectory(atPath: themeDir)
            .filter { fm.dirExists(atPath: filePathInThemeDir(name: $0)) }
            .sorted(by: { $0 < $1 })
    }
    
    func isExistTheme(name: String) -> Bool {
        return fm.dirExists(atPath: filePathInThemeDir(name: name))
    }
    
    func files(in theme: Theme) throws -> [EditableFileGroup] {
        
        let selectedThemeDir = filePathInThemeDir(name: theme.name)
        
        let scriptFiles = try enumerateEditableFiles(in: selectedThemeDir, hasExtension: Extension.script)
        let styleFiles = try enumerateEditableFiles(in: selectedThemeDir, hasExtension: Extension.style)
        let templateFiles = try enumerateEditableFiles(in: selectedThemeDir, hasExtension: Extension.template)
        
        return [
            EditableFileGroup(name: Extension.script, files: scriptFiles),
            EditableFileGroup(name: Extension.style, files: styleFiles),
            EditableFileGroup(name: Extension.template, files: templateFiles)
        ]
    }
    
    func readFileBody(using fileio: FileIO, path: String) -> Future<EditableFileBody> {
        
        return fileio.read(file: filePathInThemeDir(name: path)).map { data in
            
            guard let body = String.init(data: data, encoding: .utf8) else {
                throw Abort(.internalServerError)
            }
            
            return EditableFileBody(path: path, body: body)
        }
    }
    
    func writeFileBody(path: String, body: String) throws {
        
        let filePath = filePathInThemeDir(name: path)
        let url = URL(fileURLWithPath: filePath)

        try body.write(to: url, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Util
    
    private func filePathInThemeDir(name: String) -> String {
        return themeDir.finished(with: "/").appending(name)
    }
    
    private func enumerateEditableFiles(in path: String, hasExtension ext: String) throws -> [EditableFile] {
        
        return try fm.enumerateFiles(in: path, hasExtension: ext)
            .map { EditableFile(name: $0.name, path: String($0.absolutePath.dropFirst(themeDir.count))) }
            .sorted(by: { $0.name < $1.name })
    }
}
