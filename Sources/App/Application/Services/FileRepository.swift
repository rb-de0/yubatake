
protocol FileRepository {
    
    func files(in theme: String?) -> [AccessibleFileGroup]
    func readFileData(in theme: String?, at path: String, type: FileType, customized: Bool) throws -> String
    
    func writeUserFileData(at path: String, type: FileType, data: String) throws
    func deleteUserFileData(at path: String, type: FileType) throws
    func deleteAllUserFiles() throws
    
    func getAllThemes() throws -> [String]
    func saveTheme(as name: String) throws
    func copyTheme(name: String) throws
    func deleteTheme(name: String) throws
}
