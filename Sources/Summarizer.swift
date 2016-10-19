/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal class Summarizer {

    fileprivate let phrases: [Sentence]

    fileprivate let rank = TextRank<Sentence>()

    init(text: String) {
        self.phrases = text.sentences.map(Sentence.init)
    }

    func execute() -> [String] {
        buildGraph()
        return rank.execute()
            .sorted { $0.1 > $1.1 }
            .map { $0.0.text }
    }

    fileprivate func buildGraph() {
        let combinations = self.phrases.combinations(2)

        combinations.forEach { combo in
            addNodes(combo.first!, combo.last!)
        }
    }

    fileprivate func addNodes(_ pivotal: Sentence, _ node: Sentence) {
        let pivotalWordCount: Float = pivotal.words.count
        let nodeWordCount: Float = node.words.count

        // calculate weight by co-occurrence of words between sentences
        var score: Float = pivotal.words.filter { node.words.contains($0) }.count
        score = score / (log(pivotalWordCount) + log(nodeWordCount))

        rank.addEdge(pivotal, node, weight: score)
        rank.addEdge(node, pivotal, weight: score)
    }
}
