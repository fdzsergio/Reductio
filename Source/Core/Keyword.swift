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

    let firstIndexByWord = words.enumerated().reduce(into: [String: Int]()) { result, element in
      let (index, word) = element
      result[word] = result[word] ?? index
    }

    return ranking.execute()
      .sorted { lhs, rhs in
        if lhs.value == rhs.value {
          return firstIndexByWord[lhs.key, default: Int.max]
            < firstIndexByWord[rhs.key, default: Int.max]
        }
        return lhs.value > rhs.value
      }
      .map(\.key)
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

extension Keyword {
  fileprivate static func preprocess(_ text: String) -> [String] {
    return text.lowercased()
      .components(separatedBy: CharacterSet.letters.inverted)
  }
}
