# Text Summarization

Automatically extract the most important sentences from text to create concise summaries.

## Overview

Text summarization uses the TextRank algorithm to identify and extract the most significant sentences from a document. Unlike keyword extraction which works at the word level, summarization preserves complete sentences to maintain context and readability.

## How It Works

1. **Sentence Segmentation**
   - Text split into individual sentences
   - Sentence boundaries detected using NaturalLanguage framework
   - Preserves punctuation and formatting

2. **Sentence Representation**
   - Each sentence converted to a vector representation
   - Words weighted by importance (TF-IDF-like scoring)
   - Stopwords filtered to focus on content words

3. **Graph Construction**
   - Sentences become vertices in the graph
   - Edges connect similar sentences
   - Similarity measured by word overlap and semantic distance

4. **Ranking and Selection**
   - PageRank-style algorithm ranks sentences
   - Top-ranked sentences selected for summary
   - Original order preserved for readability

## Basic Usage

### Extract Key Sentences

```swift
let article = """
Climate change represents one of the most pressing challenges of our time. 
Rising global temperatures are causing widespread environmental impacts. 
Scientists report that immediate action is needed to prevent catastrophic consequences. 
Renewable energy adoption is accelerating as costs continue to decline. 
Many countries have committed to achieving net-zero emissions by 2050.
"""

// Get all sentences ranked by importance
let rankedSentences = await Reductio.summarize(text: article)

// Extract top 2 sentences
let summary = await Reductio.summarize(text: article, count: 2)
summary.forEach { print("• \($0)") }
```

### Compression-Based Summarization

```swift
// Keep 20% of content (80% compression)
let conciseSummary = await Reductio.summarize(text: article, compression: 0.8)
```

## Advanced Examples

### News Article Summarization

```swift
struct NewsDigest {
  static func createDigest(from articles: [NewsArticle]) async -> [ArticleSummary] {
    await withTaskGroup(of: ArticleSummary.self) { group in
      for article in articles {
        group.addTask {
          let summary = await Reductio.summarize(
            text: article.content,
            count: 3
          )
          
          return ArticleSummary(
            headline: article.headline,
            summary: summary.joined(separator: " "),
            readTime: estimateReadTime(summary),
            originalLength: article.content.count
          )
        }
      }
      
      var digests: [ArticleSummary] = []
      for await summary in group {
        digests.append(summary)
      }
      return digests
    }
  }
}
```

### Research Paper Abstract Generation

```swift
extension ResearchPaper {
  func generateAutoAbstract() async -> String {
    // Extract key sentences from each section
    async let introPoint = Reductio.summarize(text: introduction, count: 1)
    async let methodPoint = Reductio.summarize(text: methodology, count: 1)
    async let resultPoint = Reductio.summarize(text: results, count: 2)
    async let conclusionPoint = Reductio.summarize(text: conclusion, count: 1)
    
    let points = await [
      introPoint, 
      methodPoint, 
      resultPoint, 
      conclusionPoint
    ].flatMap { $0 }
    
    return points.joined(separator: " ")
  }
}
```

### Meeting Notes Summarization

```swift
class MeetingNoteSummarizer {
  func summarizeMeeting(_ transcript: String) async -> MeetingSummary {
    // Extract different types of content
    let allSentences = await Reductio.summarize(text: transcript)
    
    // Identify key points (typically 20% of content)
    let keyPoints = await Reductio.summarize(
      text: transcript, 
      compression: 0.8
    )
    
    // Find action items (sentences with action verbs)
    let actionItems = allSentences.filter { sentence in
      containsActionVerbs(sentence)
    }.prefix(5)
    
    // Find decisions (sentences with decision keywords)
    let decisions = allSentences.filter { sentence in
      containsDecisionKeywords(sentence)
    }.prefix(3)
    
    return MeetingSummary(
      keyPoints: Array(keyPoints),
      actionItems: Array(actionItems),
      decisions: Array(decisions),
      duration: estimateDuration(transcript)
    )
  }
}
```

### Document Comparison

```swift
struct DocumentComparer {
  static func compareDocuments(_ doc1: String, _ doc2: String) async -> ComparisonResult {
    async let summary1 = Reductio.summarize(text: doc1, count: 5)
    async let summary2 = Reductio.summarize(text: doc2, count: 5)
    
    let (s1, s2) = await (summary1, summary2)
    
    // Find common themes
    let commonThemes = findCommonThemes(s1, s2)
    
    // Find unique points
    let uniqueToDoc1 = findUniquePoints(s1, relativeTo: s2)
    let uniqueToDoc2 = findUniquePoints(s2, relativeTo: s1)
    
    return ComparisonResult(
      commonThemes: commonThemes,
      uniqueToFirst: uniqueToDoc1,
      uniqueToSecond: uniqueToDoc2,
      similarity: calculateSimilarity(s1, s2)
    )
  }
}
```

## Best Practices

### Input Preparation
- Ensure proper sentence boundaries (periods, proper capitalization)
- Remove headers, footers, and metadata
- Keep paragraphs intact for better context

### Summary Length
- **1-2 sentences**: Quick overview, social media
- **3-5 sentences**: Executive summaries, abstracts
- **20-30% of original**: Detailed summaries, study notes

### Quality Enhancement
- Post-process to ensure grammatical flow
- Check for pronoun references
- Verify key information is captured

## Compression Guidelines

| Use Case | Compression | Retention |
|----------|-------------|-----------|
| Headlines | 0.95 | 5% |
| Abstracts | 0.90 | 10% |
| Executive Summary | 0.80 | 20% |
| Study Notes | 0.70 | 30% |
| Detailed Summary | 0.50 | 50% |

## Limitations

- Cannot generate new sentences (extractive only)
- May miss context that spans multiple sentences
- Pronouns might lose their references
- Works best with well-structured text

## Comparison with Keyword Extraction

| Feature | Summarization | Keyword Extraction |
|---------|--------------|-------------------|
| Output | Complete sentences | Individual words |
| Context | Preserved | Lost |
| Use Case | Reading comprehension | Indexing, tagging |
| Length | Configurable | List of terms |

## See Also

- <doc:KeywordExtraction> - Extract important terms
- <doc:Performance> - Optimization strategies  
- ``summarize(text:)``