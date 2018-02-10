//The MIT License (MIT)
//
//Copyright (c) 2016 Tanner Nelson
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Leaf
import LeafProvider

final class UserLeafRenderder: ViewRenderer {
    
    public let stem: Stem
    public let cacheSize: Int
    
    public var shouldCache: Bool {
        didSet {
            if shouldCache {
                stem.cache = SystemCache<Leaf>(maxSize: cacheSize.megabytes)
            } else {
                stem.cache = nil
            }
        }
    }
    
    public init(file: FileProtocol, userFile: FileProtocol) {
        stem = Stem(UserDataFile(file: file, userFile: userFile))
        shouldCache = false
        self.cacheSize = 8
    }
    
    public func make(_ path: String, _ node: Node) throws -> View {
        return try self.make(path, Context(node))
    }
    
    public func make(_ path: String, _ context: LeafContext) throws -> View {
        let leaf = try stem.spawnLeaf(at: path)
        let bytes = try stem.render(leaf, with: context)
        return View(data: bytes)
    }
}
