# Concurrency

Leverage Swift 6's concurrency features for efficient text processing at scale.

## Overview

Reductio is fully compatible with Swift 6's strict concurrency checking, using modern async/await patterns and actor isolation for thread-safe operations. This guide covers concurrent processing patterns and best practices.

## Swift 6 Concurrency

### Sendable Conformance

All Reductio types are designed with value semantics and Sendable conformance:

```swift
// Safe to pass across isolation boundaries
let keyword = Keyword(word: "swift", stem: "swift", score: 0.95)
await processOnMainActor(keyword)  // ✅ Safe

// Arrays of results are also Sendable
let keywords = await Reductio.keywords(from: text)
await updateUI(with: keywords)  // ✅ Safe
```

### Actor Isolation

Use actors for stateful processing:

```swift
actor DocumentProcessor {
  private var processedCount = 0
  private var totalProcessingTime: TimeInterval = 0
  
  func process(_ document: Document) async -> ProcessingResult {
    let startTime = Date()
    
    async let keywords = Reductio.keywords(from: document.text, count: 20)
    async let summary = Reductio.summarize(text: document.text, count: 5)
    
    let result = await ProcessingResult(
      id: document.id,
      keywords: keywords,
      summary: summary
    )
    
    // Actor-isolated state updates
    processedCount += 1
    totalProcessingTime += Date().timeIntervalSince(startTime)
    
    return result
  }
  
  var statistics: ProcessingStatistics {
    ProcessingStatistics(
      documentsProcessed: processedCount,
      averageTime: totalProcessingTime / Double(processedCount)
    )
  }
}
```

## Concurrent Processing Patterns

### Parallel Document Processing

Process multiple documents concurrently:

```swift
func processDocuments(_ documents: [Document]) async -> [DocumentSummary] {
  await withTaskGroup(of: DocumentSummary.self) { group in
    // Add tasks for each document
    for document in documents {
      group.addTask {
        async let keywords = Reductio.keywords(from: document.content, count: 15)
        async let summary = Reductio.summarize(text: document.content, count: 3)
        
        return await DocumentSummary(
          id: document.id,
          title: document.title,
          keywords: keywords,
          summary: summary.joined(separator: " ")
        )
      }
    }
    
    // Collect results maintaining order
    var results: [DocumentSummary] = []
    for await summary in group {
      results.append(summary)
    }
    
    return results.sorted { $0.id < $1.id }
  }
}
```

### Streaming Processing

Process documents as they arrive:

```swift
struct DocumentStream {
  func processStream(_ documents: AsyncStream<Document>) async {
    await withTaskGroup(of: Void.self) { group in
      for await document in documents {
        group.addTask {
          let result = await processDocument(document)
          await saveResult(result)
        }
      }
    }
  }
  
  private func processDocument(_ document: Document) async -> ProcessedDocument {
    async let keywords = Reductio.keywords(from: document.text, count: 10)
    async let summary = Reductio.summarize(text: document.text, count: 2)
    
    return await ProcessedDocument(
      document: document,
      keywords: keywords,
      summary: summary
    )
  }
}
```

### Concurrent Analysis Pipeline

Different analyses in parallel:

```swift
struct ComprehensiveAnalyzer {
  func analyze(_ text: String) async -> Analysis {
    // Start all analyses concurrently
    async let keywords = extractKeywords(text)
    async let summary = generateSummary(text)
    async let sentiment = analyzeSentiment(text)
    async let readability = calculateReadability(text)
    async let entities = extractEntities(text)
    
    // Wait for all to complete
    return await Analysis(
      keywords: keywords,
      summary: summary,
      sentiment: sentiment,
      readability: readability,
      entities: entities
    )
  }
  
  private func extractKeywords(_ text: String) async -> KeywordAnalysis {
    let keywords = await Reductio.keywords(from: text, count: 20)
    let density = calculateDensity(keywords: keywords, in: text)
    
    return KeywordAnalysis(
      primary: Array(keywords.prefix(5)),
      secondary: Array(keywords.dropFirst(5).prefix(10)),
      density: density
    )
  }
  
  private func generateSummary(_ text: String) async -> SummaryAnalysis {
    let sentences = await Reductio.summarize(text: text, count: 5)
    let compression = Double(sentences.joined().count) / Double(text.count)
    
    return SummaryAnalysis(
      sentences: sentences,
      compressionRatio: compression,
      readingTime: estimateReadingTime(sentences)
    )
  }
}
```

## Task Priority Management

### Priority-Based Processing

Handle documents based on priority:

```swift
enum DocumentPriority {
  case high, medium, low
  
  var taskPriority: TaskPriority {
    switch self {
    case .high: return .high
    case .medium: return .medium
    case .low: return .low
    }
  }
}

func processPrioritized(_ documents: [(Document, DocumentPriority)]) async {
  await withTaskGroup(of: ProcessingResult.self) { group in
    for (document, priority) in documents {
      group.addTask(priority: priority.taskPriority) {
        await processDocument(document)
      }
    }
    
    // Results arrive based on completion, not priority
    for await result in group {
      await handleResult(result)
    }
  }
}
```

### Adaptive Concurrency

Adjust concurrency based on system resources:

```swift
struct AdaptiveProcessor {
  func processAdaptively(_ documents: [Document]) async -> [Result] {
    let maxConcurrency = determineOptimalConcurrency()
    
    return await withTaskGroup(
      of: Result.self,
      concurrency: maxConcurrency
    ) { group in
      var results: [Result] = []
      
      for document in documents {
        group.addTask {
          await processWithResourceMonitoring(document)
        }
      }
      
      for await result in group {
        results.append(result)
      }
      
      return results
    }
  }
  
  private func determineOptimalConcurrency() -> Int {
    let cpuCount = ProcessInfo.processInfo.processorCount
    let memorySize = ProcessInfo.processInfo.physicalMemory
    
    // Adjust based on available resources
    if memorySize < 4_000_000_000 { // Less than 4GB
      return max(2, cpuCount / 2)
    } else {
      return cpuCount
    }
  }
}
```

## Cancellation Support

### Cooperative Cancellation

Handle task cancellation gracefully:

```swift
func processWithCancellation(_ documents: [Document]) async throws -> [Result] {
  try await withThrowingTaskGroup(of: Result.self) { group in
    for document in documents {
      group.addTask {
        // Check cancellation before processing
        try Task.checkCancellation()
        
        // Process with cancellation checks
        let result = try await processInterruptible(document)
        
        return result
      }
    }
    
    var results: [Result] = []
    for try await result in group {
      results.append(result)
    }
    return results
  }
}

func processInterruptible(_ document: Document) async throws -> Result {
  // Check cancellation at key points
  try Task.checkCancellation()
  
  let keywords = await Reductio.keywords(from: document.text)
  
  try Task.checkCancellation()
  
  let summary = await Reductio.summarize(text: document.text)
  
  return Result(keywords: keywords, summary: summary)
}
```

### Timeout Handling

Implement processing timeouts:

```swift
func processWithTimeout(
  _ document: Document,
  timeout: Duration
) async throws -> Result {
  try await withThrowingTimeout(of: timeout) {
    await processDocument(document)
  }
}

func withThrowingTimeout<T>(
  of duration: Duration,
  operation: @Sendable () async throws -> T
) async throws -> T {
  try await withThrowingTaskGroup(of: T.self) { group in
    group.addTask {
      try await operation()
    }
    
    group.addTask {
      try await Task.sleep(for: duration)
      throw TimeoutError()
    }
    
    let result = try await group.next()!
    group.cancelAll()
    return result
  }
}
```

## Main Actor Integration

### UI Updates

Update UI from background processing:

```swift
@MainActor
class DocumentViewController: UIViewController {
  func processAndDisplay(_ document: Document) async {
    // Show loading state
    showLoadingIndicator()
    
    // Process in background
    let result = await Task.detached(priority: .userInitiated) {
      async let keywords = Reductio.keywords(from: document.text, count: 10)
      async let summary = Reductio.summarize(text: document.text, count: 3)
      
      return await (keywords, summary)
    }.value
    
    // Update UI on main actor
    hideLoadingIndicator()
    displayKeywords(result.0)
    displaySummary(result.1)
  }
}
```

### Progress Reporting

Report progress during batch processing:

```swift
@MainActor
protocol ProgressDelegate: AnyObject {
  func updateProgress(_ progress: Double)
  func processingComplete()
}

actor BatchProcessor {
  weak var delegate: ProgressDelegate?
  
  func processBatch(_ documents: [Document]) async {
    let total = documents.count
    var completed = 0
    
    await withTaskGroup(of: Void.self) { group in
      for document in documents {
        group.addTask {
          await self.processDocument(document)
          await self.reportProgress(
            completed: &completed,
            total: total
          )
        }
      }
    }
    
    await delegate?.processingComplete()
  }
  
  private func reportProgress(completed: inout Int, total: Int) async {
    completed += 1
    let progress = Double(completed) / Double(total)
    await delegate?.updateProgress(progress)
  }
}
```

## Best Practices

1. **Use Structured Concurrency**: Prefer TaskGroup over unstructured tasks
2. **Avoid Shared State**: Use actors for stateful operations
3. **Check Cancellation**: Implement cooperative cancellation in long operations
4. **Batch Appropriately**: Balance between too many small tasks and too few large ones
5. **Monitor Resources**: Adapt concurrency level based on system resources

## See Also

- <doc:Performance> - Performance optimization
- <doc:Configuration> - Configuration options
- ``keywords(from:)`` - Async API reference