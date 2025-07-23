# Keyword Extraction

Extract the most relevant keywords from text using the TextRank algorithm.

## Overview

Keyword extraction identifies the most important words in a text by analyzing their relationships and frequency patterns. Reductio uses a graph-based approach that considers not just word frequency, but also semantic relationships between words.

## How It Works

1. **Text Preprocessing**
   - Tokenization into words
   - Stopword removal (common words like "the", "is", "at")
   - Lemmatization to reduce words to base forms
   - Part-of-speech tagging to identify nouns and adjectives

2. **Graph Construction**
   - Each word becomes a vertex in the graph
   - Edges connect words that co-occur within a window
   - Edge weights represent the strength of association

3. **Ranking**
   - Initial scores assigned to all vertices
   - Scores propagate through edges iteratively
   - Convergence typically occurs after 20-30 iterations

4. **Extraction**
   - Words ranked by final scores
   - Top keywords returned based on specified criteria

## Basic Usage

### Extract All Keywords

```swift
let text = "Machine learning is transforming how we interact with technology."
let keywords = await Reductio.keywords(from: text)
// Returns all keywords ranked by importance
```

### Extract Specific Number

```swift
// Get top 5 keywords
let topKeywords = await Reductio.keywords(from: text, count: 5)
```

### Extract by Compression Ratio

```swift
// Keep top 30% of keywords (70% compression)
let compressed = await Reductio.keywords(from: text, compression: 0.7)
```

## Advanced Examples

### SEO Keyword Analysis

```swift
struct SEOAnalyzer {
  static func analyzeContent(_ content: String) async -> SEOAnalysis {
    let allKeywords = await Reductio.keywords(from: content)
    let topKeywords = Array(allKeywords.prefix(20))
    
    // Calculate keyword density
    let wordCount = content.split(separator: " ").count
    let density = topKeywords.map { keyword in
      let occurrences = content.lowercased()
        .components(separatedBy: keyword.lowercased()).count - 1
      return (keyword, Double(occurrences) / Double(wordCount) * 100)
    }
    
    return SEOAnalysis(
      primaryKeywords: Array(topKeywords.prefix(5)),
      secondaryKeywords: Array(topKeywords.dropFirst(5).prefix(10)),
      longTailKeywords: Array(topKeywords.dropFirst(15)),
      keywordDensity: Dictionary(uniqueKeysWithValues: density)
    )
  }
}
```

### Content Tagging System

```swift
class ContentTagger {
  private let tagThreshold = 0.7
  
  func generateTags(for article: String) async -> Set<String> {
    // Extract keywords
    let keywords = await Reductio.keywords(from: article, count: 15)
    
    // Filter based on relevance to predefined categories
    let relevantTags = keywords.filter { keyword in
      // Check against your taxonomy
      isRelevantTag(keyword)
    }
    
    return Set(relevantTags)
  }
}
```

### Research Paper Analysis

```swift
extension ScientificPaper {
  func extractKeyTerms() async -> KeyTermAnalysis {
    // Extract from different sections
    async let abstractKeywords = Reductio.keywords(from: abstract, count: 10)
    async let introKeywords = Reductio.keywords(from: introduction, count: 10)
    async let conclusionKeywords = Reductio.keywords(from: conclusion, count: 10)
    
    // Combine and rank
    let allKeywords = await (abstractKeywords + introKeywords + conclusionKeywords)
    let uniqueKeywords = Array(Set(allKeywords))
    
    return KeyTermAnalysis(
      coreTerms: uniqueKeywords.prefix(5),
      domainTerms: identifyDomainSpecific(from: uniqueKeywords),
      emergingTerms: identifyNovel(from: uniqueKeywords)
    )
  }
}
```

## Best Practices

### Preprocessing
- Clean text of special characters and formatting
- Consider domain-specific stopwords
- Preserve compound terms when relevant

### Optimization
- For real-time applications, cache results
- Process in batches for multiple documents
- Use compression for large-scale analysis

### Quality Improvement
- Combine with TF-IDF for better results
- Consider n-grams for multi-word keywords
- Validate against domain vocabularies

## Performance Considerations

| Document Size | Processing Time | Memory Usage |
|--------------|-----------------|--------------|
| 100 words    | ~5ms           | ~0.5 MB      |
| 1,000 words  | ~25ms          | ~2 MB        |
| 10,000 words | ~250ms         | ~10 MB       |

## Limitations

- Works best with English text
- Requires sufficient text (50+ words) for meaningful results
- May miss domain-specific terminology without customization
- Single-word keywords only (no phrases)

## See Also

- <doc:TextSummarization> - Extract key sentences
- <doc:Configuration> - Customize extraction parameters
- ``keywords(from:)`` - API reference