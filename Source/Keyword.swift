/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal final class Keyword {
    
    private let ngram: Int = 3
    private var words: [String]
    
    private let ranking = TextRank<String>()
    
    init(text: String) {
        self.words = Keyword.preprocess(text)
    }
    
    // Asynchronous execute method
    func execute() async -> [String] {
        await filterWords()
        await buildGraph()
        let rankedWords = await ranking.execute()
        return rankedWords
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
    
    // Asynchronous filterWords to allow concurrency
    func filterWords() async {
        words = await words
            .filter(removeShortWords)
            .filter(removeStopWords)
    }
    
    // Asynchronous buildGraph to avoid blocking on large datasets
    func buildGraph() async {
        await withTaskGroup(of: Void.self) { group in
            for (index, node) in words.enumerated() {
                group.addTask {
                    var (min, max) = (index - self.ngram, index + self.ngram)
                    if min < 0 { min = self.words.startIndex }
                    if max > self.words.count { max = self.words.endIndex }
                    self.words[min..<max].forEach { word in
                        self.ranking.add(edge: node, to: word)
                    }
                }
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
        return word.count > 2
    }
    
    func removeStopWords(_ word: String) -> Bool {
        return !stopwords.contains(word)
    }
}
