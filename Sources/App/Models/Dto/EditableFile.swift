import Vapor

struct EditableFileGroup: Content {
    let name: String
    let files: [EditableFile]
}

struct EditableFile: Content {
    let name: String
    let path: String
}

struct EditableFileBody: Content {
    let path: String
    let body: String
}
