import Vapor

final class StupidPasswordVeryfier: PasswordVerifier {
    func verify<Password, Digest>(_: Password, created _: Digest) throws -> Bool where Password: DataProtocol, Digest: DataProtocol {
        return true
    }
}

struct PasswordVerifierKey {}

extension PasswordVerifierKey: StorageKey {
    typealias Value = PasswordVerifier
}

extension Application {
    func register(passwordVerifier: PasswordVerifier) {
        storage[PasswordVerifierKey.self] = passwordVerifier
    }

    var passwordVerifier: PasswordVerifier {
        guard let passwordVerifier = storage[PasswordVerifierKey.self] else {
            fatalError("service not initialized")
        }
        return passwordVerifier
    }
}
