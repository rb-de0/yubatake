import Foundation

extension String {
    
    func take(n: Int) -> String{
        
        if n >= self.count {
            return self
        }
        
        return String(self[..<index(self.startIndex, offsetBy: n)])
    }
    
    func started(with start: String) -> String {
        guard !self.hasPrefix(start) else { return self }
        return start + self
    }
    
    func normalized() -> String {
        return NSString(string: string).standardizingPath
    }
    
    var deletingLastPathComponent: String {
        return String(components(separatedBy: "/").dropLast().joined(separator: "/"))
    }
}
