import Vapor

protocol FileRepository {
    func allThemes() throws -> [String]
    func isExistTheme(name: String) -> Bool

    func files(in theme: String) throws -> [EditableFileGroup]
    func readFileBody(using fileio: FileIO, path: String) -> EventLoopFuture<EditableFileBody>
    func writeFileBody(path: String, body: String) throws
}

final class DefaultFileRepository: FileRepository {

    struct Extension {
        static let script = "js"
        static let style = "css"
        static let template = "leaf"
    }

    private let fm = FileManager.default
    private let themeDirectory: String

    init(fileConfig: FileConfig) {
        themeDirectory = fileConfig.themeDirectory
    }

    func allThemes() throws -> [String] {
        return try fm.contentsOfDirectory(atPath: themeDirectory)
            .filter { fm.dirExists(atPath: filePathInThemeDir(name: $0)) }
            .sorted(by: { $0 < $1 })
    }

    func isExistTheme(name: String) -> Bool {
        return fm.dirExists(atPath: filePathInThemeDir(name: name))
    }

    func files(in theme: String) throws -> [EditableFileGroup] {
        let selectedThemeDir = filePathInThemeDir(name: theme)
        let scriptFiles = try enumerateEditableFiles(in: selectedThemeDir, hasExtension: Extension.script)
        let styleFiles = try enumerateEditableFiles(in: selectedThemeDir, hasExtension: Extension.style)
        let templateFiles = try enumerateEditableFiles(in: selectedThemeDir, hasExtension: Extension.template)
        return [
            EditableFileGroup(name: Extension.script, files: scriptFiles),
            EditableFileGroup(name: Extension.style, files: styleFiles),
            EditableFileGroup(name: Extension.template, files: templateFiles)
        ]
    }

    func readFileBody(using fileio: FileIO, path: String) -> EventLoopFuture<EditableFileBody> {
        return fileio.collectFile(at: filePathInThemeDir(name: path))
            .map { buffer in
                buffer.getString(at: 0, length: buffer.readableBytes, encoding: .utf8)
            }
            .unwrap(or: Abort(.internalServerError))
            .map { EditableFileBody(path: path, body: $0) }
    }

    func writeFileBody(path: String, body: String) throws {
        let filePath = filePathInThemeDir(name: path)
        let url = URL(fileURLWithPath: filePath)
        try body.write(to: url, atomically: true, encoding: .utf8)
    }

    // MARK: - Util

    private func filePathInThemeDir(name: String) -> String {
        return themeDirectory.finished(with: "/").appending(name)
    }

    private func enumerateEditableFiles(in path: String, hasExtension ext: String) throws -> [EditableFile] {
        return try fm.enumerateFiles(in: path, hasExtension: ext)
            .map { EditableFile(name: $0.name, path: String($0.absolutePath.dropFirst(themeDirectory.count))) }
            .sorted(by: { $0.name < $1.name })
    }
}

struct FileRepositoryKey {}

extension FileRepositoryKey: StorageKey {
    typealias Value = FileRepository
}

extension Application {
    func register(fileRepository: FileRepository) {
        storage[FileRepositoryKey.self] = fileRepository
    }

    var fileRepository: FileRepository {
        guard let fileRepository = storage[FileRepositoryKey.self] else {
            fatalError("service not initialized")
        }
        return fileRepository
    }
}
