# Getting Started

Learn how to integrate Reductio into your project and start extracting keywords and summaries from text.

## Overview

This guide walks you through the basic usage of Reductio, from installation to your first keyword extraction and text summarization.

## Quick Start

### Import the Library

```swift
import Reductio
```

### Extract Keywords

The simplest way to extract keywords from text:

```swift
let text = """
Apple Inc. announced groundbreaking updates to its developer tools at WWDC 2024. 
The company introduced Swift 6 with major improvements to concurrency and performance. 
Developers praised the new features, particularly the enhanced type safety and 
async/await improvements that make concurrent programming more intuitive.
"""

// Extract all keywords
let keywords = await Reductio.keywords(from: text)

// Extract top 5 keywords
let topKeywords = await Reductio.keywords(from: text, count: 5)
print(topKeywords)  
// Output: ["swift", "developers", "improvements", "concurrency", "features"]
```

### Summarize Text

Extract the most important sentences from a document:

```swift
// Get top 2 sentences
let summary = await Reductio.summarize(text: text, count: 2)
summary.forEach { print("• \($0)") }
```

## Using String Extensions

For convenience, Reductio provides synchronous String extensions:

```swift
// Quick keyword extraction
let keywords = text.keywords

// Get top 10 keywords
let topKeywords = text.keywords(count: 10)

// Quick summarization
let summary = text.summarize

// Get 3-sentence summary
let shortSummary = text.summarize(count: 3)
```

## Choosing Between Async and Sync APIs

### Use Async APIs When:
- Processing large documents (1000+ words)
- Building concurrent applications
- Working with Swift 6 strict concurrency
- Optimizing for performance

### Use String Extensions When:
- Quick prototyping
- Processing small text snippets
- Working in synchronous contexts
- Convenience is priority

## Next Steps

- Learn about <doc:KeywordExtraction> for advanced keyword extraction techniques
- Explore <doc:TextSummarization> for different summarization strategies
- Check <doc:Configuration> for customization options
- Review <doc:Performance> for optimization tips