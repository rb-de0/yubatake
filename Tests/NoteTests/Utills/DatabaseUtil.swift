import Foundation
import MySQL
import MySQLDriver

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
    
    class var port: UInt {
        return processInfo.environment["MYSQL_PORT"]?.uint ?? 3307
    }
    
    class func driver(database: String = "") throws -> MySQLDriver.Driver {
        let dataBase = try MySQL.Database(hostname: hostName, user: user, password: password, database: database, port: port)
        return MySQLDriver.Driver(master: dataBase)
    }
    
    class func create(name: String) throws {
        try driver().raw("create database if not exists \(name) default character set utf8;")
    }
    
    class func drop(name: String) throws {
        try driver().raw("drop database if exists \(name)")
    }
}
