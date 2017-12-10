import Foundation

extension String {
    
    func take(n: Int) -> String{
        
        if n >= self.count {
            return self
        }
        
        return String(self[..<index(self.startIndex, offsetBy: n)])
    }
}
