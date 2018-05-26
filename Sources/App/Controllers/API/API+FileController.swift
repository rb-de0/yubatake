import Vapor

extension API {
    
    final class FileController {
        
        func index(request: Request) throws -> Future<[EditableFileGroup]> {
            let repository = try request.make(FileRepository.self)
            return try request.parameters.next(Theme.self).map { theme in
                try repository.files(in: theme)
            }
        }
        
        func show(request: Request) throws -> Future<EditableFileBody> {
            let repository = try request.make(FileRepository.self)
            let form = try request.query.decode(EditableFileForm.self)
            return repository.readFileBody(using: try request.fileio(), path: form.path)
        }
        
        func store(request: Request, form: EditableFileUpdateForm) throws -> HTTPStatus {
            let repository = try request.make(FileRepository.self)
            try repository.writeFileBody(path: form.path, body: form.body)
            return HTTPStatus.ok
        }
    }
}
