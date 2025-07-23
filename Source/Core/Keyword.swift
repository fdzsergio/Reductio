/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>
 
 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

struct Keyword: Sendable {
  private let ngram: Int = 3
  private let words: [String]
  
  init(text: String) {
    self.words = Self.preprocess(text)
      .filter { $0.count > 2 }
      .filter { !stopwords.contains($0) }
  }
  
  func execute() -> [String] {
    let ranking = TextRank<String>()
    buildGraph(ranking: ranking)
    return ranking.execute()
      .sorted { $0.1 > $1.1 }
      .map { $0.0 }
  }
  
  private func buildGraph(ranking: TextRank<String>) {
    for (index, node) in words.enumerated() {
      var (min, max) = (index - ngram, index + ngram)
      if min < 0 { min = words.startIndex }
      if max > words.count { max = words.endIndex }
      words[min..<max].forEach { word in
        ranking.add(edge: node, to: word)
      }
    }
  }
}

private extension Keyword {
  static func preprocess(_ text: String) -> [String] {
    return text.lowercased()
      .components(separatedBy: CharacterSet.letters.inverted)
  }
}
