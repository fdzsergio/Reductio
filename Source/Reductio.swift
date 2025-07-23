/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

/// The main namespace for Reductio's text analysis functions.
///
/// Reductio provides powerful text summarization and keyword extraction capabilities
/// using the TextRank algorithm. All functions are designed with Swift 6 concurrency
/// in mind and are fully thread-safe.
///
/// ## Topics
///
/// ### Keyword Extraction
/// - ``keywords(from:)``
/// - ``keywords(from:count:)``
/// - ``keywords(from:compression:)``
///
/// ### Text Summarization
/// - ``summarize(text:)``
/// - ``summarize(text:count:)``
/// - ``summarize(text:compression:)``

/// Extracts all keywords from text sorted by relevance.
///
/// This function analyzes the input text using the TextRank algorithm to identify
/// and extract the most relevant keywords based on their importance in the text.
///
/// - Parameter text: The text to extract keywords from.
/// - Returns: An array of keywords sorted by relevance (most relevant first).
///
/// ## Example
/// ```swift
/// let text = "Swift is a powerful programming language. Swift is fast and modern."
/// let keywords = await keywords(from: text)
/// // Returns: ["swift", "programming", "language", "powerful", "modern", "fast"]
/// ```
public func keywords(from text: String) async -> [String] {
  text.keywords
}

/// Extracts a specified number of keywords from text sorted by relevance.
///
/// - Parameters:
///   - text: The text to extract keywords from.
///   - count: The maximum number of keywords to extract.
/// - Returns: An array of keywords sorted by relevance, limited to the specified count.
///
/// ## Example
/// ```swift
/// let text = "Swift is a powerful programming language. Swift is fast and modern."
/// let topKeywords = await keywords(from: text, count: 3)
/// // Returns: ["swift", "programming", "language"]
/// ```
public func keywords(from text: String, count: Int) async -> [String] {
  text.keywords.slice(length: count)
}

/// Extracts keywords from text with a specified compression ratio.
///
/// - Parameters:
///   - text: The text to extract keywords from.
///   - compression: The compression ratio (0.0-1.0). A value of 0.8 removes 80% of keywords.
/// - Returns: An array of keywords sorted by relevance after applying compression.
///
/// ## Example
/// ```swift
/// let text = "Swift is a powerful programming language. Swift is fast and modern."
/// let compressedKeywords = await keywords(from: text, compression: 0.5)
/// // Returns top 50% of keywords
/// ```
public func keywords(from text: String, compression: Float) async -> [String] {
  text.keywords.slice(percent: compression)
}

/// Summarizes text by extracting and reordering sentences by relevance.
///
/// This function uses the TextRank algorithm to identify the most important
/// sentences in the text based on their relationships and significance.
///
/// - Parameter text: The text to summarize.
/// - Returns: An array of sentences sorted by relevance (most relevant first).
///
/// ## Example
/// ```swift
/// let article = "Long article text with multiple sentences..."
/// let summary = await summarize(text: article)
/// // Returns sentences ordered by importance
/// ```
public func summarize(text: String) async -> [String] {
  text.summarize
}

/// Summarizes text by extracting a specified number of relevant sentences.
///
/// - Parameters:
///   - text: The text to summarize.
///   - count: The maximum number of sentences to extract.
/// - Returns: An array of sentences sorted by relevance, limited to the specified count.
///
/// ## Example
/// ```swift
/// let article = "Long article text with multiple sentences..."
/// let shortSummary = await summarize(text: article, count: 3)
/// // Returns top 3 most important sentences
/// ```
public func summarize(text: String, count: Int) async -> [String] {
  text.summarize.slice(length: count)
}

/// Summarizes text with a specified compression ratio.
///
/// - Parameters:
///   - text: The text to summarize.
///   - compression: The compression ratio (0.0-1.0). A value of 0.8 removes 80% of sentences.
/// - Returns: An array of sentences sorted by relevance after applying compression.
///
/// ## Example
/// ```swift
/// let article = "Long article text with multiple sentences..."
/// let compressedSummary = await summarize(text: article, compression: 0.7)
/// // Returns top 30% of sentences
/// ```
public func summarize(text: String, compression: Float) async -> [String] {
  text.summarize.slice(percent: compression)
}

// MARK: - String Extensions

/// String extensions for convenient text analysis.
///
/// These extensions provide synchronous access to Reductio's functionality directly
/// on String instances. For better performance with large texts or concurrent
/// processing, use the async functions in the main Reductio namespace.
///
/// ## Topics
///
/// ### Keyword Extraction
/// - ``keywords``
/// - ``keywords(count:)``
///
/// ### Text Summarization  
/// - ``summarize``
/// - ``summarize(count:)``
public extension String {
  /// Extracts all keywords from the string sorted by relevance.
  ///
  /// This property provides synchronous access to keyword extraction functionality.
  /// For async operations or better performance, use the global ``keywords(from:)`` function instead.
  ///
  /// - Returns: An array of keywords sorted by relevance (most relevant first).
  ///
  /// ## Example
  /// ```swift
  /// let text = "Swift is a powerful programming language."
  /// let keywords = text.keywords
  /// // Returns: ["swift", "programming", "language", "powerful"]
  /// ```
  ///
  /// - SeeAlso: ``keywords(from:)`` for async version
  /// - SeeAlso: ``keywords(count:)`` to limit results
  var keywords: [String] {
    Keyword(text: self).execute()
  }

  /// Summarizes the string by extracting sentences ordered by relevance.
  ///
  /// This property provides synchronous access to text summarization functionality.
  /// For async operations or better performance, use the global ``summarize(text:)`` function instead.
  ///
  /// - Returns: An array of sentences sorted by relevance (most important first).
  ///
  /// ## Example
  /// ```swift
  /// let article = "Long article text with multiple sentences..."
  /// let summary = article.summarize
  /// // Returns sentences ordered by importance
  /// ```
  ///
  /// - SeeAlso: ``summarize(text:)`` for async version
  /// - SeeAlso: ``summarize(count:)`` to limit sentences
  var summarize: [String] {
    Summarizer(text: self).execute()
  }
  
  /// Extracts a specified number of keywords from the string.
  ///
  /// - Parameter count: The maximum number of keywords to extract.
  /// - Returns: An array of keywords limited to the specified count.
  ///
  /// ## Example
  /// ```swift
  /// let text = "Swift is a powerful and modern programming language."
  /// let topKeywords = text.keywords(count: 3)
  /// // Returns: ["swift", "programming", "language"]
  /// ```
  ///
  /// - SeeAlso: ``keywords(from:count:)`` for async version
  func keywords(count: Int) -> [String] {
    Array(keywords.prefix(count))
  }
  
  /// Extracts a specified number of sentences for summarization.
  ///
  /// - Parameter count: The maximum number of sentences to extract.
  /// - Returns: An array of sentences limited to the specified count.
  ///
  /// ## Example
  /// ```swift
  /// let article = "Long article with many sentences..."
  /// let brief = article.summarize(count: 2)
  /// // Returns the 2 most important sentences
  /// ```
  ///
  /// - SeeAlso: ``summarize(text:count:)`` for async version
  func summarize(count: Int) -> [String] {
    Array(summarize.prefix(count))
  }
}
