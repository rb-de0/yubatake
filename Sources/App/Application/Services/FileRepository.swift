
protocol FileRepository {
    
    func readFileData(at path: String, type: FileType) throws -> String
    func readUserFileData(at path: String, type: FileType) throws -> String
    func writeUserFileData(at path: String, type: FileType, data: String) throws
    func deleteUserFileData(at path: String, type: FileType) throws
    func deleteAllUserFiles() throws
    
    func files(in theme: String?) -> [AccessibleFileGroup]
    func readThemeFileData(in theme: String, at path: String, type: FileType) throws -> String
    
    func getAllThemes() throws -> [String]
    func saveTheme(as name: String) throws
    func copyTheme(name: String) throws
    func deleteTheme(name: String) throws
}
