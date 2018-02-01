
struct FormError {
    
    let error: Error
    let deliverer: FormDataDeliverable.Type
    
    var errorMessage: String {
        return (error as? Debuggable)?.reason ?? error.localizedDescription
    }
    
    init(error: Error, deliverer: FormDataDeliverable.Type = NoDerivery.self) {
        self.error = error
        self.deliverer = deliverer
    }
}
