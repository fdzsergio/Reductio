# Architecture

Explore the internal design and structure of Reductio.

## Overview

Reductio is designed with modern Swift principles: protocol-oriented programming, value types, and strict concurrency. This document details the architectural decisions and internal structure.

## Design Principles

### 1. Value Semantics
All public types use structs for predictable behavior:
- Immutable by default
- Thread-safe without locks
- Predictable performance

### 2. Protocol-Oriented Design
Core functionality defined through protocols:
- Testable components
- Flexible implementations
- Clear interfaces

### 3. Zero Dependencies
Pure Swift implementation:
- No external packages
- Uses only system frameworks
- Minimal binary size

### 4. Swift 6 Concurrency
Full adoption of modern concurrency:
- Async/await APIs
- Sendable conformance
- Actor isolation where needed

## Component Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Public API Layer                       │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │  keywords() │  │ summarize()  │  │ String+Reductio│ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                   Core Processing Layer                   │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │  TextRank   │  │  Summarizer  │  │    Keyword     │ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                  Text Processing Layer                    │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │   Stemmer   │  │   Sentence   │  │    Search      │ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                    Foundation Layer                       │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │  Stopwords  │  │ Array+Combi  │  │ NaturalLanguage│ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### TextRank Engine

The heart of Reductio:

```swift
internal struct TextRank {
  private let dampingFactor: Double = 0.85
  private let convergenceThreshold: Double = 0.0001
  private let maxIterations: Int = 30
  
  func execute(on matrix: Matrix) -> [Score] {
    var scores = Array(repeating: 1.0, count: matrix.count)
    var previousScores = scores
    
    for _ in 0..<maxIterations {
      scores = iterate(matrix: matrix, scores: previousScores)
      
      if hasConverged(scores, previousScores) {
        break
      }
      
      previousScores = scores
    }
    
    return scores.enumerated()
      .sorted { $0.element > $1.element }
      .map { Score(index: $0.offset, value: $0.element) }
  }
}
```

### Keyword Processor

Manages keyword extraction pipeline:

```swift
public struct Keyword {
  let word: String
  let stem: String
  let score: Double
  
  internal init(from vertex: GraphVertex) {
    self.word = vertex.originalForm
    self.stem = vertex.normalizedForm
    self.score = vertex.rankScore
  }
}

internal struct KeywordExtractor {
  private let preprocessor: TextPreprocessor
  private let graphBuilder: GraphBuilder
  private let ranker: TextRank
  
  func extract(from text: String) -> [Keyword] {
    // 1. Preprocess
    let processed = preprocessor.process(text)
    
    // 2. Build graph
    let graph = graphBuilder.buildWordGraph(from: processed)
    
    // 3. Rank
    let scores = ranker.execute(on: graph.adjacencyMatrix)
    
    // 4. Extract keywords
    return scores
      .map { score in
        Keyword(from: graph.vertices[score.index])
      }
      .filter { $0.score > threshold }
  }
}
```

### Summarizer

Handles sentence extraction:

```swift
public struct Summarizer {
  internal let sentenceProcessor: SentenceProcessor
  internal let graphBuilder: GraphBuilder
  internal let ranker: TextRank
  
  func summarize(_ text: String, count: Int) -> [String] {
    // 1. Extract sentences
    let sentences = sentenceProcessor.extract(from: text)
    
    // 2. Build similarity graph
    let graph = graphBuilder.buildSentenceGraph(from: sentences)
    
    // 3. Rank sentences
    let scores = ranker.execute(on: graph.similarityMatrix)
    
    // 4. Select top sentences
    return scores
      .prefix(count)
      .sorted { $0.index < $1.index }  // Original order
      .map { sentences[$0.index] }
  }
}
```

### Text Processing Pipeline

#### Stemmer

Reduces words to root forms:

```swift
internal struct Stemmer {
  // Porter Stemmer implementation
  func stem(_ word: String) -> String {
    var word = word.lowercased()
    
    // Step 1a: Plurals
    word = removePlurals(word)
    
    // Step 1b: Verbal inflections
    word = removeVerbalInflections(word)
    
    // Step 1c: Y → I
    word = replaceYWithI(word)
    
    // Steps 2-5: Suffix removal
    word = removeSuffixes(word)
    
    return word
  }
}
```

#### Sentence Processor

Handles sentence segmentation:

```swift
internal struct SentenceProcessor {
  private let tokenizer: NLTokenizer
  
  init() {
    tokenizer = NLTokenizer(unit: .sentence)
  }
  
  func extract(from text: String) -> [String] {
    tokenizer.string = text
    
    var sentences: [String] = []
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
      let sentence = String(text[range])
        .trimmingCharacters(in: .whitespacesAndNewlines)
      
      if sentence.count >= minimumSentenceLength {
        sentences.append(sentence)
      }
      
      return true
    }
    
    return sentences
  }
}
```

## Data Flow

### Keyword Extraction Flow

```
Text Input
    ↓
Tokenization (NLTokenizer)
    ↓
POS Tagging (NLTagger)
    ↓
Stopword Filtering
    ↓
Stemming/Lemmatization
    ↓
Graph Construction
    ↓
TextRank Iteration
    ↓
Score Extraction
    ↓
Keyword Output
```

### Summarization Flow

```
Text Input
    ↓
Sentence Segmentation
    ↓
Sentence Vectorization
    ↓
Similarity Calculation
    ↓
Graph Construction
    ↓
TextRank Iteration
    ↓
Sentence Selection
    ↓
Summary Output
```

## Memory Management

### String Interning

Efficient string storage:

```swift
internal final class StringInterner {
  private var pool: Set<String> = []
  
  func intern(_ string: String) -> String {
    if let existing = pool.first(where: { $0 == string }) {
      return existing
    }
    pool.insert(string)
    return string
  }
}
```

### Graph Representation

Sparse matrix for efficiency:

```swift
internal struct SparseMatrix {
  private var rows: [Int: [(column: Int, value: Double)]] = [:]
  
  subscript(row: Int, column: Int) -> Double {
    get {
      rows[row]?.first { $0.column == column }?.value ?? 0
    }
    set {
      if newValue != 0 {
        if rows[row] == nil {
          rows[row] = []
        }
        rows[row]!.append((column, newValue))
      }
    }
  }
}
```

## Error Handling

### Input Validation

```swift
internal enum ValidationError: Error {
  case textTooShort(minimumLength: Int)
  case invalidCompression(value: Double)
  case invalidCount(value: Int)
}

internal struct InputValidator {
  static func validate(_ text: String) throws {
    guard text.count >= minimumTextLength else {
      throw ValidationError.textTooShort(minimumLength: minimumTextLength)
    }
  }
  
  static func validate(compression: Double) throws {
    guard (0.0...1.0).contains(compression) else {
      throw ValidationError.invalidCompression(value: compression)
    }
  }
}
```

### Graceful Degradation

```swift
internal struct SafeProcessor {
  func process(_ text: String) -> ProcessingResult {
    do {
      try InputValidator.validate(text)
      return .success(performProcessing(text))
    } catch {
      return .partial(fallbackProcessing(text))
    }
  }
}
```

## Performance Optimizations

### Lazy Evaluation

```swift
internal struct LazyGraph {
  private var computedEdges: [EdgeKey: Double] = [:]
  private let computeWeight: (Vertex, Vertex) -> Double
  
  mutating func weight(from: Vertex, to: Vertex) -> Double {
    let key = EdgeKey(from: from, to: to)
    
    if let cached = computedEdges[key] {
      return cached
    }
    
    let weight = computeWeight(from, to)
    computedEdges[key] = weight
    return weight
  }
}
```

### Batch Processing

```swift
internal struct BatchProcessor {
  func process<T>(_ items: [T], batchSize: Int = 100) -> [Result<T>] {
    items.chunked(into: batchSize).flatMap { batch in
      processBatch(batch)
    }
  }
}
```

## Testing Architecture

### Protocol-Based Testing

```swift
protocol TextProcessor {
  func process(_ text: String) -> ProcessedText
}

// Production implementation
struct NaturalLanguageProcessor: TextProcessor {
  func process(_ text: String) -> ProcessedText {
    // Real implementation
  }
}

// Test implementation
struct MockTextProcessor: TextProcessor {
  var processedResult: ProcessedText
  
  func process(_ text: String) -> ProcessedText {
    processedResult
  }
}
```

### Deterministic Testing

```swift
internal struct DeterministicRanker {
  let seed: UInt64
  
  func rank(_ items: [Item]) -> [Score] {
    // Use seeded random for consistent tests
    var generator = SeededRandomGenerator(seed: seed)
    // Deterministic ranking
  }
}
```

## Future Considerations

### Planned Enhancements

1. **Phrase Extraction**: Multi-word keywords
2. **Language Models**: Integration with CoreML
3. **Custom Dictionaries**: Domain-specific vocabularies
4. **Streaming API**: Process text as it arrives

### API Stability

Following semantic versioning:
- Major version: Breaking changes
- Minor version: New features
- Patch version: Bug fixes

### Extension Points

```swift
// Allows custom preprocessing
public protocol TextPreprocessor {
  func preprocess(_ text: String) -> PreprocessedText
}

// Allows custom ranking algorithms
public protocol RankingAlgorithm {
  func rank(_ graph: Graph) -> [Score]
}
```

## See Also

- <doc:TextRankAlgorithm> - Algorithm details
- <doc:Performance> - Performance characteristics
- <doc:Configuration> - Configuration options