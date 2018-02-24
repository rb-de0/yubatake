import Sessions

extension Post: FormDataDeliverable {
    
    static func override(node: inout Node, with formData: [String : Node]) throws {
        
        let key = makeKey(prefix: "post")
        
        try node.set(key(Post.titleKey), formData[Post.titleKey])
        
        if let categoryId = formData[Post.categoryKey]?.int {
            try node.set(key(Post.categoryKey, Category.idKey), categoryId)
        } else {
            try node.set(key(Post.categoryKey), false)
        }
        
        try node.set(key(Post.isStaticKey), formData[Post.isStaticKey])
        try node.set(key(Post.contentKey), formData[Post.contentKey])
        try node.set(key(Post.tagsStringKey), formData[Post.tagsKey])
    }
}

extension Tag: FormDataDeliverable {
    
    static func override(node: inout Node, with formData: [String : Node]) throws {
        try node.set(Tag.nameKey, formData[Tag.nameKey])
    }
}

extension Category: FormDataDeliverable {
    
    static func override(node: inout Node, with formData: [String : Node]) throws {
        try node.set(Category.nameKey, formData[Category.nameKey])
    }
}

extension User: FormDataDeliverable {
    
    static func stash(on session: Session, formData: Node) throws {
        let key = makeKey(prefix: formDataKey)
        try session.data.set(key(User.nameKey), formData[User.nameKey])
    }
    
    static func override(node: inout Node, with formData: [String : Node]) throws {
        try node.set(User.nameKey, formData[User.nameKey])
    }
}

extension SiteInfo: FormDataDeliverable {
    
    static func override(node: inout Node, with formData: [String : Node]) throws {
        try node.set(SiteInfo.nameKey, formData[SiteInfo.nameKey])
        try node.set(SiteInfo.descriptionKey, formData[SiteInfo.descriptionKey])
    }
}

