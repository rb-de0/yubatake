import Foundation

extension String {
    
    func take(n: Int) -> String{
        
        if n >= self.characters.count{
            return self
        }
        
        return self.substring(to: self.index(self.startIndex, offsetBy: n))
    }
}
