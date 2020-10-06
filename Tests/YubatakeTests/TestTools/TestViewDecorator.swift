@testable import App
import Vapor
import Leaf

final class TestViewDecorator: ViewDecorator {
    
    private var currentContext = [String: LeafData]()
    
    func decodate(context: Encodable, for request: Request) -> Encodable {
        currentContext = (try? LeafDataEncoder().encode(encodable: context)) ?? [:]
        return context
    }
    
    func get(_ key: String) -> LeafData? {
        let paths = key.components(separatedBy: ".")
        var dictionary: [String: LeafData]? = currentContext
        var result: LeafData?
        for (index, path) in paths.enumerated() {
            if index < paths.count - 1 {
                dictionary = dictionary?[path]?.dictionary
            } else {
                result = dictionary?[path]
            }
        }
        return result
    }
}

extension TestViewDecorator: StorageKey {
    typealias Value = TestViewDecorator
}

extension Application {
    func register(testViewDecorator: TestViewDecorator) {
        storage[TestViewDecorator.self] = testViewDecorator
    }

    var testViewDecorator: TestViewDecorator {
        guard let testViewDecorator = storage[TestViewDecorator.self] else {
            fatalError("service not initialized")
        }
        return testViewDecorator
    }
}
