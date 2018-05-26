import Vapor

final class BootOnlyCommand: Command, Service {
    
    let arguments: [CommandArgument] = []
    let options: [CommandOption] = []
    
    let help = ["bootonly"]
    
    func run(using context: CommandContext) throws -> Future<Void> {
        return context.container.future(())
    }
}
