import MySQL
import MySQLDriver

final class DB {
    
    private class func driver() throws -> MySQLDriver.Driver {
        let dataBase = try MySQL.Database(hostname: "127.0.0.1", user: "root", password: "root", database: "", port: 3307)
        return MySQLDriver.Driver(master: dataBase)
    }
    
    class func create(name: String) throws {
        try driver().raw("create database if not exists \(name) default character set utf8;")
    }
    
    class func drop(name: String) throws {
        try driver().raw("drop database if exists \(name)")
    }
}
