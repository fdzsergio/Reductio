/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

final class TextRank<T: Hashable & Sendable> {
  /// Configuration for TextRank algorithm execution.
  struct Configuration: Sendable {
    /// Initial score for new nodes (default: 0.15).
    let initialScore: Float

    /// Damping factor for PageRank calculation (default: 0.85).
    let dampingFactor: Float

    /// Convergence threshold (default: 0.01).
    let convergenceThreshold: Float

    /// Maximum iterations to prevent infinite loops (default: 100).
    let maxIterations: Int

    /// Minimum iteration count before checking convergence (default: 10).
    let minIterations: Int

    init(
      initialScore: Float = 0.15,
      dampingFactor: Float = 0.85,
      convergenceThreshold: Float = 0.01,
      maxIterations: Int = 100,
      minIterations: Int = 10
    ) {
      precondition(initialScore > 0 && initialScore < 1, "Initial score must be between 0 and 1")
      precondition(dampingFactor > 0 && dampingFactor < 1, "Damping factor must be between 0 and 1")
      precondition(convergenceThreshold > 0, "Convergence threshold must be positive")
      precondition(maxIterations > 0, "Max iterations must be positive")
      precondition(minIterations >= 0, "Min iterations must be non-negative")
      precondition(minIterations <= maxIterations, "Min iterations cannot exceed max iterations")

      self.initialScore = initialScore
      self.dampingFactor = dampingFactor
      self.convergenceThreshold = convergenceThreshold
      self.maxIterations = maxIterations
      self.minIterations = minIterations
    }
  }

  typealias Scores = [T: Float]

  private var incomingSourcesByNode: [T: [T]] = [:]
  private var outgoingWeightByNode: [T: Float] = [:]
  private var scores: Scores = [:]
  private var weightsBySource: [T: [T: Float]] = [:]

  private let configuration: Configuration

  init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  func add(edge source: T, to destination: T, weight: Float = 1.0) {
    guard source != destination, weight > 0, weight.isFinite else { return }

    let previousWeight = weightsBySource[source]?[destination] ?? 0
    if previousWeight == 0 {
      incomingSourcesByNode[destination, default: []].append(source)
    }

    weightsBySource[source, default: [:]][destination] = previousWeight + weight
    outgoingWeightByNode[source, default: 0] += weight

    scores[source] = scores[source] ?? configuration.initialScore
    scores[destination] = scores[destination] ?? configuration.initialScore
  }

  /// Executes the TextRank algorithm to calculate node rankings.
  /// - Returns: Final node rankings.
  func execute() -> Scores {
    guard !scores.isEmpty else { return [:] }

    var currentScores = scores

    for iterationCount in 1...configuration.maxIterations {
      let nextScores = iteration(currentScores)

      if iterationCount >= configuration.minIterations,
        hasConverged(nextScores, previous: currentScores)
      {
        return nextScores
      }

      currentScores = nextScores
    }

    return currentScores
  }

  private func iteration(_ currentScores: Scores) -> Scores {
    let baseScore = (1 - configuration.dampingFactor) / Float(currentScores.count)
    var nextScores = Scores(minimumCapacity: currentScores.count)

    for node in currentScores.keys {
      let propagatedScore = incomingSourcesByNode[node, default: []].reduce(Float.zero) {
        total, source in
        guard
          let sourceScore = currentScores[source],
          let outgoingWeight = outgoingWeightByNode[source],
          let edgeWeight = weightsBySource[source]?[node],
          outgoingWeight > 0
        else {
          return total
        }

        return total + sourceScore * edgeWeight / outgoingWeight
      }

      nextScores[node] = baseScore + configuration.dampingFactor * propagatedScore
    }

    return nextScores
  }

  private func hasConverged(_ current: Scores, previous: Scores) -> Bool {
    guard current.count == previous.count else { return false }

    let sumSquaredDifference = previous.reduce(Float.zero) { total, element in
      let (node, previousScore) = element
      let currentScore = current[node] ?? 0
      let difference = currentScore - previousScore
      return total + difference * difference
    }

    let rootMeanSquareError = sqrtf(sumSquaredDifference / Float(previous.count))
    return rootMeanSquareError < configuration.convergenceThreshold
  }
}
