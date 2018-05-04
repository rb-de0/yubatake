import Crypto
import FluentMySQL
import Vapor

final class MigrationCommand: Command, Service {
    
    let arguments: [CommandArgument] = []
    
    let options: [CommandOption] = [
        .value(name: "input", short: "i", help: ["old database"])
    ]
    
    let help: [String] = ["Migrating note to 3.0.0 from 2.1.2"]
    
    private var _oldConn: MySQLConnection?
    private var _newConn: MySQLConnection?
    
    private var oldConn: MySQLConnection {
        guard let _oldConn = _oldConn else {
            fatalError()
        }
        return _oldConn
    }
    
    private var newConn: MySQLConnection {
        guard let _newConn = _newConn else {
            fatalError()
        }
        return _newConn
    }
    
    func run(using context: CommandContext) throws -> Future<Void> {
        
        guard let old = context.options["input"] else {
            fatalError("Invalid Option")
        }

        let container = context.container
        let config = try context.container.make(MySQLDatabaseConfig.self)
        let oldDataBaseConfig = MySQLDatabaseConfig(
            hostname: config.hostname,
            port: config.port,
            username: config.username,
            password: config.password,
            database: old
        )

        let oldDataBase = MySQLDatabase(config: oldDataBaseConfig)
        let newDataBase = MySQLDatabase(config: config)
        let worker = MultiThreadedEventLoopGroup(numThreads: 1)
        
        _oldConn = try oldDataBase.newConnection(on: worker).wait()
        _newConn = try newDataBase.newConnection(on: worker).wait()
        
        return deleteAllModels(on: container)
            .flatMap {
                self.migrate(on: container, NewSchema<User>.self)
            }
            .flatMap {
                self.makeUserPassword(on: container)
            }
            .flatMap {
                self.migrate(on: container, from: OldCategory.self, to: NewSchema<Category>.self)
            }
            .flatMap {
                self.migrate(on: container, NewSchema<Tag>.self)
            }
            .flatMap {
                self.migrate(on: container, from: OldPost.self, to: NewSchema<Post>.self)
            }
            .flatMap {
                self.migrate(on: container, NewSchema<PostTag>.self)
            }
            .flatMap {
                self.migrate(on: container, from: OldSiteInfo.self, to: NewSchema<SiteInfo>.self)
            }
            .flatMap {
                self.migrate(on: container, NewSchema<Image>.self)
            }
            .always {
                self.oldConn.close()
                self.newConn.close()
            }
    }
    
    // MARK: - Migrations
    
    private func deleteAllModels(on container: Container) -> Future<Void> {

        return deleteAll(on: container, Image.self)
            .flatMap {
                self.deleteAll(on: container, SiteInfo.self)
            }
            .flatMap {
                self.deleteAll(on: container, PostTag.self)
            }
            .flatMap {
                self.deleteAll(on: container, Post.self)
            }
            .flatMap {
                self.deleteAll(on: container, Tag.self)
            }
            .flatMap {
                self.deleteAll(on: container, Category.self)
            }
            .flatMap {
                self.deleteAll(on: container, User.self)
            }
    }
    
    private func makeUserPassword(on container: Container) -> Future<Void> {
        
        let conn = newConn
        
        return Future.flatMap(on: container) {
            return try User.find(1, on: conn).unwrap(or: Abort(HTTPStatus.internalServerError))
                .flatMap { user in
                    let logger = try container.make(Logger.self)
                    let rootUser = try User.makeRootUser(using: container)
                    logger.warning("New Password: \(rootUser.rawPassword)")
                    user.password = rootUser.user.password
                    return user.save(on: conn).transform(to: ())
            }
        }
    }
    
    // MARK: - Helper
    
    private func deleteAll<T>(on container: Container, _ type: T.Type) -> Future<Void> where T: MySQLModel {
        
        let conn = newConn
        
        return Future.flatMap(on: container) {
            return T.query(on: conn).all()
                .flatMap { models in
                    let deleteAll = models.map { $0.delete(on: conn) }
                    return Future<Void>.andAll(deleteAll, eventLoop: conn.eventLoop)
                }
                .flatMap {
                    conn.query("alter table \(T.entity) auto_increment = 1;", []).transform(to: ())
                }
        }
    }
    
    private func migrate<T>(on container: Container, _ type: T.Type) -> Future<Void> where T: MySQLModel {
        
        let logger = try? container.make(Logger.self)
        logger?.info("migrating \(T.entity)")
        
        let conn = oldConn
        
        return Future.flatMap(on: container) {
            T.query(on: conn).all()
        }
        .flatMap { models in
            self.create(on: container, models)
        }
    }
    
    private func migrate<T, U>(on container: Container, from fromType: T.Type, to toType: U.Type) -> Future<Void> where T: OldSchemaType, T.NewSchemaType == U, U: MySQLModel {
        
        let logger = try? container.make(Logger.self)
        logger?.info("migrating \(U.entity)")
        
        let conn = oldConn
        
        return Future.flatMap(on: container) {
            return T.query(on: conn).all().map { oldModels in
                return oldModels.map { oldModel -> U in
                    return oldModel.new
                }
            }
        }
        .flatMap { models in
            self.create(on: container, models)
        }
    }
    
    private func create<T>(on container: Container, _ models: [T]) -> Future<Void> where T: MySQLModel {
        
        let conn = newConn
        
        return Future.flatMap(on: container) {
            let eventLoop = conn.eventLoop
            let saveAll = models.map { $0.create(on: conn).transform(to: ()) }
            return Future<Void>.andAll(saveAll, eventLoop: eventLoop)
        }
    }
}

// MARK: - Schema Base

fileprivate protocol OldSchemaType: MySQLModel {
    associatedtype NewSchemaType
    var new: NewSchemaType { get }
}

extension OldSchemaType {
    
    var id: Int? {
        get { fatalError() }
        set { fatalError() }
    }
    
    func encode(to encoder: Encoder) throws { fatalError() }
}

// No Timestampable Model Wrapper
fileprivate struct NewSchema<T: MySQLModel>: MySQLModel {
    
    static var entity: String {
        return T.entity
    }
    
    var id: Int? {
        get {
           return content.id
        }
        set {
            content.id = newValue
        }
    }
    
    var content: T
    
    init(from decoder: Decoder) throws {
        content = try T.init(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try content.encode(to: encoder)
    }
}

// MARK: - Old Schema

fileprivate extension MigrationCommand {
    
    private struct OldCategory: OldSchemaType {
        
        static var entity: String {
            return "categorys"
        }
        
        let new: NewSchema<Category>
        
        init(from decoder: Decoder) throws {
            new = try NewSchema<Category>(from: decoder)
        }
    }

    private struct OldSiteInfo: OldSchemaType {
        
        static var entity: String {
            return "site_infos"
        }
        
        let new: NewSchema<SiteInfo>
        
        init(from decoder: Decoder) throws {
            new = try NewSchema<SiteInfo>(from: decoder)
        }
    }
    
    private struct OldPost: OldSchemaType {
        
        private enum CodingKeys: String, CodingKey {
            case createdAt = "createdAt"
            case updatedAt = "updatedAt"
        }
        
        static var entity: String {
            return "posts"
        }
        
        let new: NewSchema<Post>
        
        init(from decoder: Decoder) throws {
            new = try NewSchema<Post>(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            new.content.createdAt = try container.decode(Date.self, forKey: .createdAt)
            new.content.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }
}
