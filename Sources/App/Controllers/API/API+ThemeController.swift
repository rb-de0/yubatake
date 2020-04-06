import Vapor

extension API {

    final class ThemeController {

        func index(request: Request) throws -> EventLoopFuture<[Theme]> {
            let repository = request.application.fileRepository
            let themes = try repository.allThemes()
            return SiteInfo.shared(on: request.db)
                .map { siteInfo in
                    themes.map { Theme(name: $0, selected: $0 == siteInfo.selectedTheme) }
                }
        }

        func store(request: Request) throws -> EventLoopFuture<Response> {
            let form = try request.content.decode(ThemeForm.self)
            return SiteInfo.shared(on: request.db)
                .flatMap { siteInfo -> EventLoopFuture<Void> in
                    siteInfo.theme = form.name
                    return siteInfo.save(on: request.db)
                }
                .transform(to: Response(status: .ok))
        }
    }
}
