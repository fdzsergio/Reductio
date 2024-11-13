/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */
import Foundation

internal extension Array {
    
    var count: Float {
        return Float(self.count as Int)
    }
    
    private func addCombo(previous: [Element], pivotal: [Element]) -> [([Element], [Element])] {
        var pivotal = pivotal
        return (0..<pivotal.count).map { _ -> ([Element], [Element]) in
            return (previous + [pivotal.remove(at: 0)], pivotal)
        }
    }
    
    // Asynchronous combinations function to allow concurrency
    func combinations(length: Int) async -> [[Element]] {
        return await withTaskGroup(of: [Element].self) { group in
            var results: [[Element]] = []
            
            for _ in 1...length {
                group.addTask {
                    let initial: [([Element], [Element])] = [([], self)]
                    let combos = initial.reduce(into: [[Element]]()) { result, pair in
                        let newCombos = self.addCombo(previous: pair.0, pivotal: pair.1)
                        result.append(contentsOf: newCombos.map { $0.0 })
                    }
                    return combos.flatMap { $0 }
                }
            }
            
            for await result in group {
                results.append(result)
            }
            
            return results
        }
    }



    
    func slice(length: Int) -> [Element] {
        return self.prefix(length).map { $0 }
    }
    
    func slice(percent: Float) -> [Element] {
        if 0.0...1.0 ~= percent {
            let count = Int((1 - percent) * Float(self.count))
            return slice(length: count)
        }
        return []
    }
}

internal extension Array {
    func asyncMap<T>(_ transform: (Element) async -> T) async -> [T] {
        var results = [T]()
        for element in self {
            let result = await transform(element)
            results.append(result)
        }
        return results
    }
}
