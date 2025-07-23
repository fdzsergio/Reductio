# ``Reductio``

Powerful text summarization and keyword extraction for Swift using the TextRank algorithm.

## Overview

Reductio is a high-performance Swift library that brings the power of automatic text analysis to your applications. Built with Swift 6's strict concurrency in mind, it provides a modern, safe, and efficient way to extract meaning from text through keyword extraction and automatic summarization.

### Key Features

- **🔑 Keyword Extraction**: Identify the most relevant keywords using graph-based ranking
- **📝 Text Summarization**: Extract key sentences while preserving context
- **⚡ High Performance**: Efficiently process documents up to 10,000+ words
- **🔒 Thread-Safe**: Full Swift 6 strict concurrency compliance
- **📦 Zero Dependencies**: Pure Swift implementation

### How It Works

Reductio implements the TextRank algorithm, an unsupervised graph-based ranking algorithm inspired by Google's PageRank. The algorithm builds a graph representation of text where:

1. **Vertices** represent words (for keyword extraction) or sentences (for summarization)
2. **Edges** represent semantic relationships between elements
3. **Weights** are calculated based on co-occurrence patterns
4. **Ranking** is performed iteratively until convergence

## Topics

### Getting Started
- <doc:GettingStarted>
- <doc:Installation>

### Core Features
- <doc:KeywordExtraction>
- <doc:TextSummarization>

### Advanced Usage
- <doc:Configuration>
- <doc:Performance>
- <doc:Concurrency>

### API Reference
- ``keywords(from:)``
- ``keywords(from:count:)``
- ``keywords(from:compression:)``
- ``summarize(text:)``
- ``summarize(text:count:)``
- ``summarize(text:compression:)``

### Implementation Details
- <doc:TextRankAlgorithm>
- <doc:Architecture>