import Vapor

struct DeletePostsForm: Content {
    let posts: [Int]?
}

struct DeleteCategoriesForm: Content {
    let categories: [Int]?
}

struct DeleteTagsForm: Content {
    let tags: [Int]?
}
