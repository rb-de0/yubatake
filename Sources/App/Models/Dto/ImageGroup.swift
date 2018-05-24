import Vapor

struct ImageGroup: PageResponse {
    
    let date: String
    let images: [Image.Public]
    
    static func make(from images: [Image.Public], on container: Container) throws -> [ImageGroup] {
        
        class Group {
            let date: Date
            var images: [Image.Public]
            
            init(date: Date, images: [Image.Public]) {
                self.date = date
                self.images = images
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = try container.make(ApplicationConfig.self).imageGroupDateFormat
        
        let calendar = Calendar.current
        var groups = [Group]()
        
        for image in images {
            guard let createdAt = image.image.createdAt else {
                continue
            }
            if let group = groups.first(where: { calendar.isDate(createdAt, inSameDayAs: $0.date) }) {
                group.images.append(image)
            } else {
                groups.append(Group(date: createdAt, images: [image]))
            }
        }
        
        return groups
            .sorted(by: { $0.date > $1.date })
            .map {
                ImageGroup(date: formatter.string(from: $0.date), images: $0.images)
            }
    }
}
