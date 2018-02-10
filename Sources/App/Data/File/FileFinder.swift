import Foundation

final class FileFinder {
    
    class func find(group: FileConfig.ResourceGroup, userPath: String = "") -> FileGroup {
        
        let rootDir = group.rootDir
        let groupDir = (rootDir.finished(with: "/") + userPath).normalized()
        let customized = !userPath.isEmpty
        let searchPath = (groupDir.finished(with: "/") + group.relativePath).normalized()
        let files = searchFiles(in: searchPath, ext: group.fileExtension, ignoring: group.ignoreDirectory)
        
        return FileGroup(rootDir: rootDir, groupDir: groupDir, customized: customized, files: files)
    }
    
    private class func searchFiles(in directory: String, ext: String, ignoring ignoreDirectory: String?) -> [File] {
        
        let contents = FileManager.default.contents(in: directory)
        
        let directories = contents.filter { $0.isDir }.filter { $0.name != ignoreDirectory }
        let targetFiles = contents.filter { !$0.isDir }.filter { $0.name.hasSuffix(ext) }
        
        return targetFiles + directories.flatMap { searchFiles(in: $0.fullPath, ext: ext, ignoring: nil) }
    }
}
