import Authentication
import Vapor

final class StupidPasswordVeryfier: PasswordVerifier, Service {
    
    func verify(_ password: LosslessDataConvertible, created hash: LosslessDataConvertible) throws -> Bool {
        return true
    }
}
