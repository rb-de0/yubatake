import Foundation
import MySQL

final class DB {
    
    private class var processInfo: ProcessInfo {
        return ProcessInfo.processInfo
    }
    
    class var hostName: String {
        return processInfo.environment["MYSQL_HOSTNAME"] ?? "127.0.0.1"
    }
    
    class var user: String {
        return processInfo.environment["MYSQL_USER"] ?? "root"
    }
    
    class var password: String {
        return processInfo.environment["MYSQL_PASSWORD"] ?? "root"
    }
    
    class var port: Int {
        return processInfo.environment["MYSQL_PORT"]?.intValue ?? 3307
    }
}
