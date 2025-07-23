# Configuration

Customize Reductio's behavior for optimal results in your specific use case.

## Overview

While Reductio works great out of the box, understanding its configuration options helps you fine-tune results for your specific domain and requirements.

## Extraction Parameters

### Count-Based Extraction

Specify exact number of results:

```swift
// Keywords
let top10Keywords = await Reductio.keywords(from: text, count: 10)

// Sentences  
let threeSentenceSummary = await Reductio.summarize(text: text, count: 3)
```

**When to use:**
- Fixed-length outputs required
- UI constraints (e.g., limited display space)
- Consistent output format needed

### Compression-Based Extraction

Specify percentage to remove:

```swift
// Keep top 30% of keywords (remove 70%)
let keywords = await Reductio.keywords(from: text, compression: 0.7)

// Keep 20% of sentences (remove 80%)
let summary = await Reductio.summarize(text: text, compression: 0.8)
```

**When to use:**
- Proportional reduction needed
- Varying document lengths
- Percentage-based requirements

### Automatic Extraction

Let the algorithm decide:

```swift
// All keywords ranked by importance
let allKeywords = await Reductio.keywords(from: text)

// All sentences ranked by importance
let allSentences = await Reductio.summarize(text: text)
```

**When to use:**
- Full analysis needed
- Custom filtering logic
- Research and exploration

## Domain Customization

### Custom Stopwords

While Reductio includes comprehensive stopwords, you might need domain-specific filtering:

```swift
extension String {
  func domainKeywords(excludeTerms: Set<String>) -> [String] {
    let keywords = self.keywords
    return keywords.filter { !excludeTerms.contains($0.lowercased()) }
  }
}

// Usage
let medicalStopwords: Set<String> = ["patient", "doctor", "hospital"]
let specificKeywords = text.domainKeywords(excludeTerms: medicalStopwords)
```

### Technical Text Processing

For technical documentation:

```swift
struct TechnicalDocProcessor {
  static func process(_ documentation: String) async -> ProcessedDoc {
    // Preserve code blocks
    let textOnly = removeCodeBlocks(from: documentation)
    
    // Extract keywords with higher count for technical terms
    let keywords = await Reductio.keywords(from: textOnly, count: 20)
    
    // Summarize with lower compression for detail preservation
    let summary = await Reductio.summarize(
      text: textOnly,
      compression: 0.6  // Keep 40% for technical accuracy
    )
    
    return ProcessedDoc(
      keywords: keywords,
      summary: summary,
      codeExamples: extractCodeBlocks(from: documentation)
    )
  }
}
```

### Academic Text Processing

For research papers and academic content:

```swift
struct AcademicProcessor {
  static func processAcademicText(_ text: String) async -> AcademicAnalysis {
    // Higher retention for academic precision
    let detailedSummary = await Reductio.summarize(
      text: text,
      compression: 0.5  // Keep 50%
    )
    
    // More keywords for comprehensive coverage
    let keywords = await Reductio.keywords(from: text, count: 30)
    
    // Separate technical terms
    let technicalTerms = keywords.filter { term in
      isTechnicalTerm(term) || containsLatinPrefix(term)
    }
    
    return AcademicAnalysis(
      abstract: detailedSummary.prefix(5).joined(separator: " "),
      keywords: keywords,
      technicalTerms: technicalTerms
    )
  }
}
```

## Performance Tuning

### Batch Processing

Process multiple documents efficiently:

```swift
func batchProcess(_ documents: [String]) async -> [DocumentSummary] {
  await withTaskGroup(of: DocumentSummary.self) { group in
    for (index, document) in documents.enumerated() {
      group.addTask {
        async let keywords = Reductio.keywords(from: document, count: 10)
        async let summary = Reductio.summarize(text: document, count: 3)
        
        return await DocumentSummary(
          id: index,
          keywords: keywords,
          summary: summary
        )
      }
    }
    
    var results: [DocumentSummary] = []
    for await summary in group {
      results.append(summary)
    }
    return results.sorted { $0.id < $1.id }
  }
}
```

### Caching Strategy

Implement caching for repeated analysis:

```swift
actor DocumentCache {
  private var keywordCache: [String: [String]] = [:]
  private var summaryCache: [String: [String]] = [:]
  
  func keywords(for text: String, count: Int) async -> [String] {
    let cacheKey = "\(text.hashValue)-\(count)"
    
    if let cached = keywordCache[cacheKey] {
      return cached
    }
    
    let keywords = await Reductio.keywords(from: text, count: count)
    keywordCache[cacheKey] = keywords
    return keywords
  }
}
```

## Language Considerations

### Multi-language Support

While optimized for English, Reductio can work with other languages:

```swift
extension String {
  var detectedLanguage: String? {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(self)
    return recognizer.dominantLanguage?.rawValue
  }
  
  func processMultilingual() async -> MultilingualResult {
    guard let language = detectedLanguage else {
      return .unsupported
    }
    
    switch language {
    case "en":
      // Optimal support
      return .processed(
        keywords: await Reductio.keywords(from: self),
        summary: await Reductio.summarize(text: self)
      )
    case "es", "fr", "de":
      // Good support
      return .processed(
        keywords: await Reductio.keywords(from: self, count: 15),
        summary: await Reductio.summarize(text: self, compression: 0.7)
      )
    default:
      // Basic support
      return .limited(
        keywords: await Reductio.keywords(from: self, count: 10)
      )
    }
  }
}
```

## Recommended Configurations

### By Use Case

| Use Case | Keywords | Summary | Compression |
|----------|----------|---------|-------------|
| News | 5-10 | 2-3 sentences | 0.8-0.9 |
| Academic | 20-30 | 5-10 sentences | 0.5-0.7 |
| Social Media | 3-5 | 1-2 sentences | 0.9-0.95 |
| Technical Docs | 15-25 | 3-5 sentences | 0.6-0.8 |
| Legal | 25-40 | 5-8 sentences | 0.4-0.6 |

### By Document Length

| Document Size | Keyword Count | Summary Sentences |
|--------------|---------------|-------------------|
| < 100 words | 3-5 | 1 |
| 100-500 words | 5-10 | 2-3 |
| 500-1000 words | 10-15 | 3-5 |
| 1000-5000 words | 15-25 | 5-8 |
| > 5000 words | 25-40 | 8-12 |

## See Also

- <doc:Performance> - Optimization strategies
- <doc:KeywordExtraction> - Keyword extraction details
- <doc:TextSummarization> - Summarization options