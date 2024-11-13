/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal final class TextRank<T: Hashable> {
    
    typealias Node      = [T: Float]
    typealias Edge      = [T: Float]
    typealias Graph     = [T: [T]]
    typealias Matrix    = [T: Node]
    
    fileprivate var graph       = Graph()
    fileprivate var outlinks    = Edge()
    fileprivate var nodes       = Node()
    fileprivate var weights     = Matrix()
    
    let score: Float = 0.15
    let damping: Float = 0.85
    let convergence: Float = 0.01
    
    func add(edge from: T, to: T, weight: Float = 1.0) {
        if from == to { return }
        
        add(node: from, to: to)
        add(weight: from, to: to, weight: weight)
        increment(outlinks: from)
    }
    
    // Asynchronous execute method to avoid blocking the main thread
    func execute() async -> Node {
        var stepNodes = await iteration(nodes)
        while !convergence(stepNodes, nodes: nodes) {
            nodes = stepNodes
            stepNodes = await iteration(nodes)
        }
        return nodes
    }
    
    // Asynchronous iteration for each PageRank step
    private func iteration(_ nodes: Node) async -> Node {
        var vertex = Node()
        await withTaskGroup(of: Void.self) { group in
            for (node, links) in graph {
                group.addTask {
                    let score: Float = links.reduce(0.0) {
                        $0 + nodes[$1] / outlinks[$1] * weights[$1, node]
                    }
                    vertex[node] = (1 - self.damping) / nodes.count + self.damping * score
                }
            }
        }
        return vertex
    }
    
    // Check for convergence
    private func convergence(_ current: Node, nodes: Node) -> Bool {
        if current == nodes { return true }
        
        let total: Float = nodes.reduce(0.0) {
            $0 + pow(current[$1.key] - $1.value, 2)
        }
        return sqrtf(total / nodes.count) < convergence
    }
}

private extension TextRank {
    
    func increment(outlinks source: T) {
        outlinks[source, default: 0] += 1
    }
    
    func add(node from: T, to: T) {
        graph[to, default: []].append(from)
        nodes[from] = score
        nodes[to] = score
    }
    
    func add(weight from: T, to: T, weight: Float) {
        weights[from, default: [:]][to] = weight
    }
}

private extension Dictionary where Key: Hashable, Value == Float {
    
    subscript (key: Key) -> Float {
        return self[key] ?? 0
    }
    
    subscript (from: Key, to: Key) -> Float {
        return (self[from] as? [Key: Float])?[to] ?? 0
    }
    
    var count: Float {
        return Float(self.count)
    }
}
