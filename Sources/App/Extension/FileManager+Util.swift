import Foundation

extension FileManager {
    func dirExists(atPath path: String) -> Bool {
        var isDir = ObjCBool(false)
        let exist = fileExists(atPath: path, isDirectory: &isDir)
        return isDir.boolValue && exist
    }

    func enumerateFiles(in path: String, hasExtension ext: String) throws -> [File] {
        let contents = try contentsOfDirectory(atPath: path)
            .map { File(name: $0, absolutePath: path.finished(with: "/").appending($0)) }
        let directories = contents.filter { $0.isDirPath }
        let files = contents.filter { !$0.isDirPath }.filter { $0.name.hasSuffix(ext) }
        let nestedFiles = try directories.flatMap { try enumerateFiles(in: $0.absolutePath, hasExtension: ext) }
        return files + nestedFiles
    }
}

extension FileManager {
    struct File {
        let name: String
        let absolutePath: String

        var isDirPath: Bool {
            var isDir = ObjCBool(false)
            _ = FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDir)
            return isDir.boolValue
        }
    }
}
