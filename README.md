# Reductio

<p align="center">
  <img src="Source/Documentation.docc/Resources/logo.png" alt="Reductio Logo" width="300"/>
  <br>
  <br>
  <strong>Text Summarization and Keyword Extraction for Swift</strong>
  <br>
  <br>
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0">
  </a>
  <a href="https://github.com/fdzsergio/Reductio/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
  </a>
  <a href="https://github.com/apple/swift-package-manager">
    <img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg" alt="Swift Package Manager">
  </a>
  <br>
  <img src="https://img.shields.io/badge/Platform-iOS%2013%2B%20%7C%20macOS%2012%2B%20%7C%20tvOS%2013%2B%20%7C%20watchOS%206%2B-lightgray" alt="Platform Support">
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#requirements">Requirements</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

## Overview

**Reductio** is a high-performance Swift library that implements the [TextRank algorithm](https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf) for automatic text summarization and keyword extraction. Built with Swift 6's strict concurrency in mind, it provides a modern, safe, and efficient way to analyze and extract meaning from text.

### What is TextRank?

TextRank is an unsupervised graph-based ranking algorithm inspired by Google's PageRank. It builds a graph representation of text where vertices are words or sentences, and edges represent semantic relationships. Through iterative calculation, it identifies the most important elements in the text.

### Use Cases

- 📰 **News Summarization**: Extract key points from articles
- 🔍 **SEO Optimization**: Identify important keywords for content
- 📚 **Academic Research**: Summarize research papers and extract key concepts
- 📱 **Social Media**: Analyze and summarize user-generated content
- 🏢 **Business Intelligence**: Process reports and extract insights
- 💬 **Chatbots**: Generate concise responses from knowledge bases

## Features

### Core Capabilities
- **🔑 Keyword Extraction**: Identify the most relevant keywords using graph-based ranking
- **📝 Text Summarization**: Extract key sentences while preserving context
- **🌐 Language Support**: Optimized for English with extensible architecture
- **⚡ High Performance**: Efficient processing of documents up to 10,000+ words
- **🔒 Thread-Safe**: Full Swift 6 strict concurrency compliance
- **📦 Zero Dependencies**: Pure Swift implementation

### Technical Highlights
- **Modern Swift APIs**: Native async/await support
- **Value Semantics**: Immutable structs for `Keyword` and `Summarizer`
- **NaturalLanguage Framework**: Leverages Apple's ML-powered text processing
- **Flexible Configuration**: Customizable compression ratios and result counts
- **Extension-Friendly**: Convenient String extensions for quick access

## Requirements

- **Swift**: 6.0+
- **Xcode**: 15.0+
- **Platforms**:
  - iOS 13.0+
  - macOS 12.0+
  - tvOS 13.0+
  - watchOS 6.0+

## Installation

### Swift Package Manager

Add Reductio to your `Package.swift` dependencies:

```swift
dependencies: [
  .package(url: "https://github.com/fdzsergio/Reductio.git", from: "1.6.0")
]
```

Then add it to your target:

```swift
targets: [
  .target(
    name: "YourApp",
    dependencies: ["Reductio"]
  )
]
```

## Usage

### Quick Start

```swift
import Reductio

let text = """
Apple Inc. announced groundbreaking updates to its developer tools at WWDC 2024. 
The company introduced Swift 6 with major improvements to concurrency and performance. 
Developers praised the new features, particularly the enhanced type safety and 
async/await improvements that make concurrent programming more intuitive.
"""

// Extract top keywords
let keywords = await Reductio.keywords(from: text, count: 5)
print(keywords)  // ["swift", "developers", "improvements", "concurrency", "features"]

// Get a summary
let summary = await Reductio.summarize(text: text, count: 2)
summary.forEach { print("• \($0)") }
```

### Keyword Extraction

#### Basic Usage

```swift
// Extract all keywords ranked by importance
let allKeywords = await Reductio.keywords(from: text)

// Get top 10 keywords
let topKeywords = await Reductio.keywords(from: text, count: 10)

// Extract keywords with 70% compression (top 30% of keywords)
let compressedKeywords = await Reductio.keywords(from: text, compression: 0.7)
```

#### Using String Extensions

```swift
// Synchronous keyword extraction
let keywords = text.keywords

// Custom configuration
let topKeywords = text.keywords(count: 5)
```

### Text Summarization

#### Sentence Extraction

```swift
// Get all sentences ranked by importance
let rankedSentences = await Reductio.summarize(text: text)

// Extract top 3 most important sentences
let summary = await Reductio.summarize(text: text, count: 3)

// Summarize with 80% compression (keep 20% of sentences)
let conciseSummary = await Reductio.summarize(text: text, compression: 0.8)
```

#### String Extension

```swift
// Quick summarization
let summary = text.summarize

// Custom length
let shortSummary = text.summarize(count: 2)
```

### Advanced Examples

#### Document Analysis Pipeline

```swift
struct DocumentAnalyzer {
  static func analyze(_ document: String) async -> DocumentInsights {
    async let keywords = Reductio.keywords(from: document, count: 10)
    async let summary = Reductio.summarize(text: document, count: 5)
    
    return await DocumentInsights(
      keywords: keywords,
      summary: summary,
      readingTime: estimateReadingTime(document)
    )
  }
}
```

#### SEO Content Optimizer

```swift
extension String {
  func seoAnalysis() async -> SEOReport {
    let keywords = await Reductio.keywords(from: self, count: 20)
    let keywordDensity = calculateDensity(keywords: keywords, in: self)
    
    return SEOReport(
      primaryKeywords: Array(keywords.prefix(5)),
      secondaryKeywords: Array(keywords.dropFirst(5)),
      keywordDensity: keywordDensity,
      suggestedMetaDescription: self.summarize(count: 1).first ?? ""
    )
  }
}
```

## Documentation

Get started with documentation at [https://fdzsergio.github.io/Reductio/](https://fdzsergio.github.io/Reductio/documentation/reductio)

### How TextRank Works

1. **Text Preprocessing**
   - Sentence segmentation using NaturalLanguage framework
   - Word tokenization and normalization
   - Stopword removal (common words like "the", "is", "at")
   - Lemmatization to reduce words to base forms

2. **Graph Construction**
   - Each word/sentence becomes a vertex
   - Edges connect co-occurring elements
   - Edge weights represent semantic similarity

3. **Iterative Ranking**
   - Initial scores assigned to all vertices
   - Scores propagate through edges
   - Convergence achieved after ~30 iterations

4. **Result Extraction**
   - Vertices ranked by final scores
   - Top elements returned as keywords/summary

### Performance Considerations

| Document Size | Processing Time | Memory Usage |
|--------------|-----------------|--------------|
| 100 words    | ~10ms          | ~1 MB        |
| 1,000 words  | ~50ms          | ~5 MB        |
| 10,000 words | ~500ms         | ~20 MB       |

For optimal performance:
- Process documents under 10,000 words
- Use compression ratios between 0.7-0.9
- Cache results for repeated analysis
- Consider chunking very large documents

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/fdzsergio/Reductio.git
cd Reductio

# Build the project
swift build

# Run tests
swift test

# Generate documentation
swift package plugin generate-documentation
```

### Code Style

- Follow Swift API Design Guidelines
- Use swift-format for consistency
- Write tests for new features
- Update documentation as needed

## License

Reductio is released under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- 🎨 Logo design by [@cristinareina](http://cristinareinadesign.com)
- 📚 Based on [TextRank](https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf) by Rada Mihalcea and Paul Tarau
- 🙏 Thanks to all [contributors](https://github.com/fdzsergio/Reductio/graphs/contributors)

## Contact

**Sergio Fernández**  
📧 fdz.sergio@gmail.com  
🐦 [@fdzsergio](https://twitter.com/fdzsergio)  
💼 [LinkedIn](https://linkedin.com/in/fdzsergio)

---

<p align="center">
  Made with ❤️ and Swift
</p>
