import FluentKit
import Foundation

struct PageResponse<T: Codable>: ResponseContent {

    let items: [T]
    let metadata: Metadata

    init(page: Page<T>) {
        items = page.items
        metadata = Metadata(meta: page.metadata)
    }
}

extension PageResponse {
    struct Metadata: Codable {
        let page: Int
        let per: Int
        let total: Int
        let totalPage: Int

        init(meta: PageMetadata) {
            page = meta.page
            per = meta.per
            total = meta.total
            totalPage = Int(ceil(Double(meta.total) / Double(meta.per)))
        }
    }
}
