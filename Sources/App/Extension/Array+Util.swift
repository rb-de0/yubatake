extension Array {
    
    func take(n: Int) -> [Element] {
        
        if n >= self.count {
            return self
        }
        
        return Array(self[..<index(self.startIndex, offsetBy: n)])
    }
}
