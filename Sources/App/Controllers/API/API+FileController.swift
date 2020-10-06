import Vapor

extension API {

    final class FileController {

        func index(request: Request) throws -> EventLoopFuture<[EditableFileGroup]> {
            guard let parameter = request.parameters.get("name", as: String.self) else {
                throw Abort(.badRequest)
            }
            let path = try parameter.requireAllowedPath()
            let repository = request.application.fileRepository
            guard repository.isExistTheme(name: path) else {
                throw Abort(.notFound)
            }
            let fileGroups = try repository.files(in: path)
            return request.eventLoop.future(fileGroups)
        }

        func show(request: Request) throws -> EventLoopFuture<EditableFileBody> {
            let query = try request.query.decode(EditableFileForm.self)
            let repository = request.application.fileRepository
            return repository.readFileBody(using: request.fileio, path: query.path)
        }

        func store(request: Request) throws -> EventLoopFuture<Response> {
            let form = try request.content.decode(EditableFileUpdateForm.self)
            let repository = request.application.fileRepository
            try repository.writeFileBody(path: form.path, body: form.body)
            return request.eventLoop.future(Response(status: .ok))
        }
    }
}
