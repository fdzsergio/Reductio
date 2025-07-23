# TextRank Algorithm

Understanding the graph-based ranking algorithm that powers Reductio.

## Overview

TextRank is an unsupervised graph-based ranking algorithm for text processing, inspired by Google's PageRank. It builds a graph representation of text where vertices represent text units (words or sentences) and edges represent semantic relationships. Through iterative calculation, it identifies the most important elements without requiring training data.

## Algorithm Foundation

### Core Principle

The TextRank formula adapts PageRank for text:

```
WS(Vᵢ) = (1-d) + d × Σ(weight(eⱼᵢ)/Σweight(eⱼₖ) × WS(Vⱼ))
```

Where:
- `WS(Vᵢ)` - importance score of vertex i
- `d` - damping factor (typically 0.85)
- `weight(eⱼᵢ)` - edge weight between vertices j and i
- The sum is over all vertices j that link to i

### Graph Construction

#### For Keyword Extraction

1. **Vertices**: Words that pass filters
   - Nouns and adjectives (using part-of-speech tagging)
   - Not in stopword list
   - Minimum length requirements

2. **Edges**: Co-occurrence relationships
   - Words within a sliding window (typically 2-5 words)
   - Undirected edges (bidirectional relationships)
   - Weight based on co-occurrence frequency

3. **Example Graph**:
```
Text: "Swift programming is powerful. Swift is modern."

Vertices: [swift, programming, powerful, modern]
Edges: 
  swift <-> programming (weight: 1)
  programming <-> powerful (weight: 1)
  swift <-> modern (weight: 1)
```

#### For Sentence Extraction

1. **Vertices**: Complete sentences
   - Sentence boundaries from NaturalLanguage framework
   - Minimum length threshold

2. **Edges**: Similarity relationships
   - Based on shared words (normalized by sentence length)
   - Weight = |shared words| / (log|S1| + log|S2|)

3. **Example Similarity**:
```
S1: "Machine learning transforms data analysis"
S2: "Data analysis uses machine learning techniques"

Shared words: {machine, learning, data, analysis}
Similarity score: 4 / (log(5) + log(6)) ≈ 0.67
```

## Implementation Details

### 1. Preprocessing Phase

```swift
struct TextPreprocessor {
  func preprocess(_ text: String) -> PreprocessedText {
    // Sentence segmentation
    let sentences = segmentSentences(text)
    
    // Word tokenization and filtering
    let tokens = sentences.map { sentence in
      tokenize(sentence)
        .filter { isValidWord($0) }
        .map { lemmatize($0) }
    }
    
    return PreprocessedText(
      sentences: sentences,
      tokens: tokens,
      vocabulary: buildVocabulary(tokens)
    )
  }
  
  private func isValidWord(_ word: String) -> Bool {
    !stopwords.contains(word.lowercased()) &&
    word.count >= minimumWordLength &&
    isContentWord(word)  // Noun or adjective
  }
}
```

### 2. Graph Building Phase

```swift
struct GraphBuilder {
  func buildWordGraph(from tokens: [[String]]) -> Graph<String> {
    var graph = Graph<String>()
    
    // Add vertices
    let uniqueWords = Set(tokens.flatMap { $0 })
    uniqueWords.forEach { graph.addVertex($0) }
    
    // Add edges with co-occurrence window
    for sentence in tokens {
      for i in 0..<sentence.count {
        let windowEnd = min(i + windowSize, sentence.count)
        for j in (i+1)..<windowEnd {
          graph.addEdge(
            from: sentence[i],
            to: sentence[j],
            weight: 1.0
          )
        }
      }
    }
    
    return graph
  }
  
  func buildSentenceGraph(from sentences: [String]) -> Graph<Int> {
    var graph = Graph<Int>()
    
    // Add vertices (sentence indices)
    for i in 0..<sentences.count {
      graph.addVertex(i)
    }
    
    // Add weighted edges based on similarity
    for i in 0..<sentences.count {
      for j in (i+1)..<sentences.count {
        let similarity = calculateSimilarity(
          sentences[i],
          sentences[j]
        )
        if similarity > threshold {
          graph.addEdge(
            from: i,
            to: j,
            weight: similarity
          )
        }
      }
    }
    
    return graph
  }
}
```

### 3. Ranking Phase

```swift
struct TextRanker {
  let dampingFactor = 0.85
  let convergenceThreshold = 0.0001
  let maxIterations = 30
  
  func rank<T>(_ graph: Graph<T>) -> [T: Double] {
    var scores = initializeScores(graph)
    var previousScores = scores
    
    for iteration in 0..<maxIterations {
      // Calculate new scores
      for vertex in graph.vertices {
        scores[vertex] = calculateScore(
          for: vertex,
          in: graph,
          with: previousScores
        )
      }
      
      // Check convergence
      if hasConverged(scores, previousScores) {
        break
      }
      
      previousScores = scores
    }
    
    return scores
  }
  
  private func calculateScore<T>(
    for vertex: T,
    in graph: Graph<T>,
    with scores: [T: Double]
  ) -> Double {
    let incomingScore = graph.neighbors(of: vertex)
      .map { neighbor in
        let edge = graph.edge(from: neighbor, to: vertex)!
        let outDegree = graph.weightedOutDegree(of: neighbor)
        return (edge.weight / outDegree) * scores[neighbor]!
      }
      .reduce(0, +)
    
    return (1 - dampingFactor) + dampingFactor * incomingScore
  }
}
```

### 4. Post-processing Phase

```swift
struct ResultExtractor {
  func extractKeywords(
    from scores: [String: Double],
    count: Int? = nil,
    compression: Double? = nil
  ) -> [String] {
    // Sort by score
    let sorted = scores.sorted { $0.value > $1.value }
    
    // Apply extraction criteria
    let extracted: [(String, Double)]
    if let count = count {
      extracted = Array(sorted.prefix(count))
    } else if let compression = compression {
      let keepCount = Int(Double(sorted.count) * (1 - compression))
      extracted = Array(sorted.prefix(keepCount))
    } else {
      extracted = sorted
    }
    
    // Return words only
    return extracted.map { $0.0 }
  }
  
  func extractSentences(
    from scores: [Int: Double],
    sentences: [String],
    count: Int
  ) -> [String] {
    // Get top scoring sentence indices
    let topIndices = scores
      .sorted { $0.value > $1.value }
      .prefix(count)
      .map { $0.key }
      .sorted()  // Maintain original order
    
    // Return sentences
    return topIndices.map { sentences[$0] }
  }
}
```

## Algorithm Characteristics

### Advantages

1. **Unsupervised**: No training data required
2. **Language Independent**: Works with any language (with appropriate preprocessing)
3. **Domain Independent**: No domain-specific knowledge needed
4. **Theoretically Sound**: Based on proven graph algorithms

### Limitations

1. **Single Words Only**: Standard TextRank extracts individual words, not phrases
2. **Context Window**: Limited context consideration (window-based)
3. **Computational Cost**: O(n²) complexity for graph construction
4. **Sentence Boundaries**: Depends on accurate sentence segmentation

## Optimizations in Reductio

### 1. Sparse Matrix Representation

```swift
// Instead of full adjacency matrix, use sparse representation
struct SparseGraph {
  private var adjacencyList: [Vertex: [(Vertex, Weight)]] = [:]
  
  // More memory efficient for typical text graphs
}
```

### 2. Early Convergence Detection

```swift
// Stop iterations when changes are minimal
if maxChange < convergenceThreshold {
  return scores  // Converged early
}
```

### 3. Parallel Score Calculation

```swift
// Calculate scores for non-dependent vertices in parallel
await withTaskGroup(of: (Vertex, Score).self) { group in
  for vertex in graph.vertices {
    group.addTask {
      let score = calculateScore(for: vertex)
      return (vertex, score)
    }
  }
}
```

## Comparison with Other Algorithms

| Algorithm | Type | Training | Speed | Quality |
|-----------|------|----------|-------|---------|
| TextRank | Graph-based | No | Medium | Good |
| TF-IDF | Statistical | No | Fast | Good |
| BERT-based | Neural | Yes | Slow | Excellent |
| LexRank | Graph-based | No | Medium | Good |

## Mathematical Properties

### Convergence Guarantee

TextRank is guaranteed to converge because:
1. The graph is strongly connected (through damping)
2. The transition matrix is stochastic
3. The power iteration method converges to the principal eigenvector

### Time Complexity

- Graph construction: O(n²) where n is number of vertices
- Ranking iterations: O(k × m) where k is iterations, m is edges
- Total: O(n² + k × m)

### Space Complexity

- Graph storage: O(n + m) for adjacency list
- Score vectors: O(n)
- Total: O(n + m)

## References

1. Mihalcea, R., & Tarau, P. (2004). "TextRank: Bringing Order into Texts"
2. Page, L., Brin, S., Motwani, R., & Winograd, T. (1999). "The PageRank Citation Ranking"
3. Barrios, F., López, F., Argerich, L., & Wachenchauzer, R. (2016). "Variations of the Similarity Function of TextRank"

## See Also

- <doc:KeywordExtraction> - Practical keyword extraction
- <doc:TextSummarization> - Practical summarization
- <doc:Architecture> - Implementation architecture