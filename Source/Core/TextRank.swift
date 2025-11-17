/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

final class TextRank<T: Hashable & Sendable> {
  /// Configuration for TextRank algorithm execution
  struct Configuration: Sendable {
    /// Initial score for new nodes (default: 0.15)
    let initialScore: Float

    /// Damping factor for PageRank calculation (default: 0.85)
    let dampingFactor: Float

    /// Convergence threshold (default: 0.01)
    let convergenceThreshold: Float

    /// Maximum iterations to prevent infinite loops (default: 100)
    let maxIterations: Int

    /// Minimum iteration count before checking convergence (default: 10)
    let minIterations: Int

    init(
      initialScore: Float = 0.15,
      dampingFactor: Float = 0.85,
      convergenceThreshold: Float = 0.01,
      maxIterations: Int = 100,
      minIterations: Int = 10
    ) {
      // Validate parameters
      precondition(initialScore > 0 && initialScore < 1, "Initial score must be between 0 and 1")
      precondition(dampingFactor > 0 && dampingFactor < 1, "Damping factor must be between 0 and 1")
      precondition(convergenceThreshold > 0, "Convergence threshold must be positive")
      precondition(maxIterations > 0, "Max iterations must be positive")
      precondition(minIterations >= 0, "Min iterations must be non-negative")

      self.initialScore = initialScore
      self.dampingFactor = dampingFactor
      self.convergenceThreshold = convergenceThreshold
      self.maxIterations = maxIterations
      self.minIterations = minIterations
    }
  }

  typealias Node = [T: Float]
  typealias Edge = [T: Float]
  typealias Graph = [T: [T]]
  typealias Matrix = [T: Node]

  private var graph = Graph()
  private var outlinks = Edge()
  private var nodes = Node()
  private var weights = Matrix()

  private let configuration: Configuration

  init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  func add(edge from: T, to: T, weight: Float = 1.0) {
    if from == to { return }

    add(node: from, to: to)
    add(weigth: from, to: to, weight: weight)
    increment(outlinks: from)
  }

  /// Executes the TextRank algorithm to calculate node rankings.
  /// - Returns: Final node rankings, or empty dictionary if execution fails
  func execute() -> Node {
    // Validate we have nodes to process
    guard !nodes.isEmpty else {
      return Node()
    }

    var currentNodes = nodes
    var iterationCount = 0

    // Iteratively calculate rankings
    while iterationCount < configuration.maxIterations {
      guard let stepNodes = iteration(currentNodes) else {
        // Invalid calculation detected (NaN/Inf), return best effort
        return currentNodes
      }

      iterationCount += 1

      // Only check convergence after minimum iterations
      if iterationCount >= configuration.minIterations {
        if hasConverged(stepNodes, previous: currentNodes) {
          return stepNodes
        }
      }

      currentNodes = stepNodes
    }

    // Max iterations reached - return last valid state
    return currentNodes
  }

  /// Performs one iteration to calculate the PageRank ranking for all nodes.
  /// - Parameter nodes: Current node values
  /// - Returns: Updated node values, or nil if calculation produces invalid values
  private func iteration(_ nodes: Node) -> Node? {
    var vertex = Node()

    for (node, links) in graph {
      // Calculate weighted score from incoming links
      var score: Float = 0.0

      for link in links {
        let nodeValue = nodes[link] ?? 0
        let outlinkValue = outlinks[link] ?? 1
        let weightValue = weights[link]?[node] ?? 0

        // Guard against division by zero and invalid weights
        guard outlinkValue > 0, !outlinkValue.isNaN, !outlinkValue.isInfinite else {
          continue
        }

        let contribution = nodeValue / outlinkValue * weightValue

        // Check for NaN or infinite values
        guard !contribution.isNaN, !contribution.isInfinite else {
          continue
        }

        score += contribution
      }

      // Calculate final vertex value using PageRank formula
      let nodeCount = Float(nodes.count)
      guard nodeCount > 0 else { return nil }

      let dampingComponent = (1 - configuration.dampingFactor) / nodeCount
      let rankComponent = configuration.dampingFactor * score
      let finalValue = dampingComponent + rankComponent

      // Validate final value
      guard !finalValue.isNaN, !finalValue.isInfinite else {
        return nil
      }

      vertex[node] = finalValue
    }

    return vertex.isEmpty ? nil : vertex
  }

  /// Check if the algorithm has converged by comparing consecutive iterations.
  /// - Parameters:
  ///   - current: Current node values
  ///   - previous: Previous node values
  /// - Returns: True if converged within threshold
  private func hasConverged(_ current: Node, previous: Node) -> Bool {
    // Early return if identical
    if current == previous { return true }

    // Calculate root mean square error
    var sumSquaredDiff: Float = 0.0
    var validComparisons = 0

    for (key, previousValue) in previous {
      guard let currentValue = current[key] else { continue }

      // Skip invalid values
      guard !currentValue.isNaN, !currentValue.isInfinite,
            !previousValue.isNaN, !previousValue.isInfinite else {
        continue
      }

      let diff = currentValue - previousValue
      sumSquaredDiff += diff * diff
      validComparisons += 1
    }

    // If no valid comparisons, consider not converged
    guard validComparisons > 0 else { return false }

    let rmse = sqrtf(sumSquaredDiff / Float(validComparisons))
    return rmse < configuration.convergenceThreshold
  }
}

private extension TextRank {
  func increment(outlinks source: T) {
    if let links = outlinks[source] {
      outlinks[source] = links + 1
    } else {
      outlinks[source] = 1
    }
  }

  func add(node from: T, to: T) {
    if var node = graph[to] {
      node.append(from)
      graph[to] = node
    } else {
      graph[to] = [from]
    }

    // Initialize nodes with validated score
    let initialScore = max(0.0, min(1.0, configuration.initialScore))
    nodes[from] = nodes[from] ?? initialScore
    nodes[to] = nodes[to] ?? initialScore
  }

  func add(weigth from: T, to: T, weight: Float) {
    if weights[from] == nil {
      weights[from] = Node()
    }
    weights[from]?[to] = weight
  }
}

private extension Dictionary {
  subscript(key: Key) -> Float {
    return self[key] as? Float ?? 0
  }

  subscript(from: Key, to: Key) -> Float {
    guard
      let row = self[from] as? [Key: Float],
      let value = row[to]
    else {
      return 0
    }
    return value
  }

  var count: Float {
    return Float(self.count as Int)
  }
}
