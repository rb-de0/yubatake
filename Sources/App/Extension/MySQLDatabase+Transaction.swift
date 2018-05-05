import FluentMySQL

extension MySQLDatabase {
    
    // TODO: Remove after generic transaction is implemented
    static func inTransaction<T>(on connection: MySQLConnection, run: @escaping (MySQLConnection) -> Future<T>) -> Future<T> {
        
        return connection.simpleQuery("START TRANSACTION").flatMap { _ in
            return run(connection).flatMap { value in
                return connection.simpleQuery("COMMIT").transform(to: value)
            }
        }
        .catchFlatMap { error in
            connection.simpleQuery("ROLLBACK").flatMap { _ in
                throw error
            }
        }
    }
}
