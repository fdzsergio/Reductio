/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

struct Summarizer: Sendable {
  private let phrases: [Sentence]

  init(text: String) {
    self.phrases = text.sentences.map(Sentence.init)
  }

  func execute() -> [String] {
    let rank = TextRank<Sentence>()
    buildGraph(rank: rank)

    let firstIndexBySentence = phrases.enumerated().reduce(into: [Sentence: Int]()) {
      result, element in
      let (index, sentence) = element
      result[sentence] = result[sentence] ?? index
    }

    return rank.execute()
      .sorted { lhs, rhs in
        if lhs.value == rhs.value {
          return firstIndexBySentence[lhs.key, default: Int.max]
            < firstIndexBySentence[rhs.key, default: Int.max]
        }
        return lhs.value > rhs.value
      }
      .map { $0.key.text }
  }

  private func buildGraph(rank: TextRank<Sentence>) {
    for index in phrases.indices.dropLast() {
      for other in phrases.index(after: index)..<phrases.endIndex {
        add(edge: phrases[index], node: phrases[other], rank: rank)
      }
    }
  }

  private func add(edge pivotal: Sentence, node: Sentence, rank: TextRank<Sentence>) {
    let pivotalWordCount = Float(pivotal.words.count)
    let nodeWordCount = Float(node.words.count)
    let denominator = log(pivotalWordCount) + log(nodeWordCount)

    guard denominator > 0 else { return }

    let nodeWords = Set(node.words)
    let sharedWordCount = pivotal.words.filter { nodeWords.contains($0) }.count
    let score = Float(sharedWordCount) / denominator

    rank.add(edge: pivotal, to: node, weight: score)
    rank.add(edge: node, to: pivotal, weight: score)
  }
}

extension String {
  fileprivate var sentences: [String] {
    var sentences = [String]()

    self.enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) {
      (substring, _, _, _) in
      if let substring = substring {
        sentences.append(substring)
      }
    }

    return sentences
  }
}
