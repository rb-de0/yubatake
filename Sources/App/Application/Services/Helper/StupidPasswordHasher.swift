import Vapor

final class StupidPasswordHasher: PasswordHasher {

    func hash<Password>(_ password: Password) throws -> [UInt8] where Password: DataProtocol {
        let string = String(decoding: password, as: UTF8.self)
        let digest = try Bcrypt.hash(string)
        return .init(digest.utf8)
    }

    func verify<Password, Digest>(_: Password, created _: Digest) throws -> Bool where Password: DataProtocol, Digest: DataProtocol {
        return true
    }
}

extension Application.Passwords.Provider {
    public static var stupid: Self {
        .stupidHasher()
    }

    public static func stupidHasher() -> Self {
        .init {
            $0.passwords.use { _ in
                StupidPasswordHasher()
            }
        }
    }
}
