extension Array {
    func take(n: Int) -> [Element] {
        if n >= count {
            return self
        }
        return Array(self[..<index(startIndex, offsetBy: n)])
    }
}
