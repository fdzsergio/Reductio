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
    return rank.execute()
      .sorted { $0.1 > $1.1 }
      .map { $0.0.text }
  }

  private func buildGraph(rank: TextRank<Sentence>) {
    let combinations = self.phrases.combinations(length: 2)

    combinations.forEach { combo in
      guard combo.count == 2,
            let first = combo.first,
            let last = combo.last
      else { return }
      add(edge: first, node: last, rank: rank)
    }
  }

  private func add(edge pivotal: Sentence, node: Sentence, rank: TextRank<Sentence>) {
    let pivotalWordCount: Float = Float(pivotal.words.count)
    let nodeWordCount: Float = Float(node.words.count)

    // calculate weight by co-occurrence of words between sentences
    var score: Float = Float(pivotal.words.filter { node.words.contains($0) }.count)
    score = score / (log(pivotalWordCount) + log(nodeWordCount))

    rank.add(edge: pivotal, to: node, weight: score)
    rank.add(edge: node, to: pivotal, weight: score)
  }
}


private extension String {
  var sentences: [String] {
    var sentences = [String]()

    self.enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) { (substring, _, _, _) in
      if let substring = substring {
        sentences.append(substring)
      }
    }

    return sentences
  }
}
