# Performance

Optimize Reductio for speed and efficiency in your applications.

## Overview

Reductio is designed for high performance, processing documents efficiently even at scale. This guide covers performance characteristics, optimization strategies, and best practices for different use cases.

## Performance Characteristics

### Processing Speed

| Document Size | Keywords Time | Summary Time | Memory Peak |
|--------------|---------------|--------------|-------------|
| 100 words | ~5ms | ~8ms | ~1 MB |
| 500 words | ~15ms | ~25ms | ~3 MB |
| 1,000 words | ~25ms | ~40ms | ~5 MB |
| 5,000 words | ~125ms | ~200ms | ~15 MB |
| 10,000 words | ~250ms | ~400ms | ~25 MB |

*Measured on Apple M1, results may vary*

### Complexity Analysis

- **Time Complexity**: O(n²) for graph construction, O(n) for ranking iterations
- **Space Complexity**: O(n²) for similarity matrix
- **Iterations**: Typically converges in 20-30 iterations

## Optimization Strategies

### 1. Preprocessing Optimization

Cache preprocessed text for repeated analysis:

```swift
struct OptimizedProcessor {
  private let preprocessCache = NSCache<NSString, ProcessedText>()
  
  func processDocument(_ text: String) async -> DocumentAnalysis {
    let cacheKey = NSString(string: text.hashValue.description)
    
    // Check cache for preprocessed data
    if let cached = preprocessCache.object(forKey: cacheKey) {
      return await analyze(cached)
    }
    
    // Preprocess once
    let processed = preprocess(text)
    preprocessCache.setObject(processed, forKey: cacheKey)
    
    return await analyze(processed)
  }
}
```

### 2. Batch Processing

Process multiple documents concurrently:

```swift
func processBatch(_ documents: [Document]) async -> [Result] {
  // Optimal concurrency based on system
  let maxConcurrency = ProcessInfo.processInfo.processorCount
  
  return await withTaskGroup(
    of: Result.self,
    concurrency: maxConcurrency
  ) { group in
    for document in documents {
      group.addTask {
        await processDocument(document)
      }
    }
    
    var results: [Result] = []
    for await result in group {
      results.append(result)
    }
    return results
  }
}
```

### 3. Streaming Processing

Handle large documents in chunks:

```swift
struct StreamingProcessor {
  let chunkSize = 5000 // words
  
  func processLargeDocument(_ text: String) async -> StreamingResult {
    let chunks = text.chunked(by: chunkSize)
    var aggregatedKeywords: [String: Double] = [:]
    var keySentences: [String] = []
    
    for chunk in chunks {
      async let keywords = Reductio.keywords(from: chunk)
      async let sentences = Reductio.summarize(text: chunk, count: 2)
      
      // Aggregate results
      let (chunkKeywords, chunkSentences) = await (keywords, sentences)
      mergeKeywords(&aggregatedKeywords, chunkKeywords)
      keySentences.append(contentsOf: chunkSentences)
    }
    
    return StreamingResult(
      keywords: topKeywords(from: aggregatedKeywords),
      summary: rankSentences(keySentences)
    )
  }
}
```

### 4. Memory Management

Efficient memory usage for iOS/watchOS:

```swift
class MemoryEfficientProcessor {
  func processWithMemoryLimit(_ text: String) async -> Result? {
    // Check available memory
    let availableMemory = getAvailableMemory()
    let estimatedMemory = estimateMemoryUsage(for: text.count)
    
    guard estimatedMemory < availableMemory * 0.5 else {
      // Fallback to chunked processing
      return await processInChunks(text)
    }
    
    // Use autorelease pool for iOS
    return await autoreleasepool {
      await processNormally(text)
    }
  }
  
  private func processInChunks(_ text: String) async -> Result {
    // Process smaller chunks to stay within memory limits
    let safeChunkSize = 1000 // words
    // Implementation...
  }
}
```

### 5. Caching Strategy

Implement intelligent caching:

```swift
actor SmartCache {
  private var cache: [CacheKey: CachedResult] = [:]
  private let maxCacheSize = 100
  private let maxAge: TimeInterval = 3600 // 1 hour
  
  func getOrCompute(
    text: String,
    type: AnalysisType
  ) async -> AnalysisResult {
    let key = CacheKey(textHash: text.hashValue, type: type)
    
    // Check cache
    if let cached = cache[key],
       Date().timeIntervalSince(cached.timestamp) < maxAge {
      return cached.result
    }
    
    // Compute result
    let result = await compute(text: text, type: type)
    
    // Update cache with LRU eviction
    await updateCache(key: key, result: result)
    
    return result
  }
  
  private func updateCache(key: CacheKey, result: AnalysisResult) {
    if cache.count >= maxCacheSize {
      evictOldest()
    }
    cache[key] = CachedResult(result: result, timestamp: Date())
  }
}
```

## Platform-Specific Optimizations

### iOS Optimization

```swift
#if os(iOS)
extension DocumentProcessor {
  func processForMobile(_ text: String) async -> MobileResult {
    // Reduce iterations for battery efficiency
    let options = ProcessingOptions(
      maxIterations: 20,  // Default is 30
      convergenceThreshold: 0.01  // Less strict
    )
    
    // Use lower counts for mobile
    async let keywords = Reductio.keywords(from: text, count: 10)
    async let summary = Reductio.summarize(text: text, count: 3)
    
    return await MobileResult(
      keywords: keywords,
      summary: summary,
      processingTime: measureTime()
    )
  }
}
#endif
```

### macOS Optimization

```swift
#if os(macOS)
extension DocumentProcessor {
  func processForDesktop(_ text: String) async -> DesktopResult {
    // Utilize multiple cores
    let coreCount = ProcessInfo.processInfo.processorCount
    
    // Parallel processing for different analyses
    async let keywords = Reductio.keywords(from: text, count: 30)
    async let summary = Reductio.summarize(text: text, count: 10)
    async let entities = extractNamedEntities(from: text)
    async let sentiment = analyzeSentiment(text: text)
    
    return await DesktopResult(
      keywords: keywords,
      summary: summary,
      entities: entities,
      sentiment: sentiment
    )
  }
}
#endif
```

### watchOS Optimization

```swift
#if os(watchOS)
extension DocumentProcessor {
  func processForWatch(_ text: String) async -> WatchResult {
    // Aggressive limits for watch
    let truncatedText = String(text.prefix(500))
    
    // Minimal processing
    let keywords = await Reductio.keywords(
      from: truncatedText,
      count: 5
    )
    
    let summary = await Reductio.summarize(
      text: truncatedText,
      count: 1
    )
    
    return WatchResult(
      keywords: keywords,
      briefSummary: summary.first ?? ""
    )
  }
}
#endif
```

## Benchmarking

### Performance Testing

```swift
func benchmarkPerformance() async {
  let testSizes = [100, 500, 1000, 5000, 10000]
  
  for size in testSizes {
    let text = generateText(wordCount: size)
    
    let startTime = CFAbsoluteTimeGetCurrent()
    _ = await Reductio.keywords(from: text)
    let keywordTime = CFAbsoluteTimeGetCurrent() - startTime
    
    let summaryStart = CFAbsoluteTimeGetCurrent()
    _ = await Reductio.summarize(text: text)
    let summaryTime = CFAbsoluteTimeGetCurrent() - summaryStart
    
    print("""
      Size: \(size) words
      Keywords: \(String(format: "%.2f", keywordTime * 1000))ms
      Summary: \(String(format: "%.2f", summaryTime * 1000))ms
      """)
  }
}
```

### Memory Profiling

```swift
func profileMemoryUsage() async {
  let info = mach_task_basic_info()
  var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
  
  let initialMemory = getMemoryUsage()
  
  // Process large document
  let largeText = generateText(wordCount: 10000)
  _ = await Reductio.keywords(from: largeText)
  
  let peakMemory = getMemoryUsage()
  let memoryUsed = peakMemory - initialMemory
  
  print("Memory used: \(memoryUsed / 1024 / 1024) MB")
}
```

## Best Practices

1. **Preprocess Once**: Cache preprocessing results for repeated analysis
2. **Batch Similar Sizes**: Group documents of similar size for batch processing
3. **Monitor Memory**: Implement memory warnings handling on iOS
4. **Use Compression**: Higher compression ratios for better performance
5. **Async Everything**: Leverage Swift concurrency for responsive UIs

## See Also

- <doc:Configuration> - Fine-tune for your use case
- <doc:Concurrency> - Concurrent processing patterns
- <doc:TextRankAlgorithm> - Algorithm details