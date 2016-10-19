/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal class Keyword {

    fileprivate let ngram: Int = 3
    fileprivate var words: [String]

    fileprivate lazy var ranking = TextRank<String>()

    init(text: String) {
        self.words = Keyword.preprocess(text)
    }

    func execute() -> [String] {
        filterWords()
        buildGraph()
        return ranking.execute()
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    func filterWords() {
        self.words = self.words
            .filter(removeShortWords)
            .filter(removeStopWords)
    }

    func buildGraph() {
        for (index, node) in words.enumerated() {
            var (min, max) = (index-ngram, index+ngram)
            if min < 0 { min = words.startIndex }
            if max > words.count { max = words.endIndex }
            words[min..<max].forEach { word in
                ranking.addEdge(node, word)
            }
        }
    }
}

private extension Keyword {

    static func preprocess(_ text: String) -> [String] {
        return text.lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
    }

    func removeShortWords(_ word: String) -> Bool {
        return word.characters.count > 2
    }

    func removeStopWords(_ word: String) -> Bool {
        return !Stopwords.contains(word)
    }
}
