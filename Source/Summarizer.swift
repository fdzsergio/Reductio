/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal final class Summarizer {
    
    private let phrases: [Sentence]
    private let rank = TextRank<Sentence>()
    
    init(text: String) async {
        self.phrases = await text.sentences.asyncMap { await Sentence.create(text: $0) }
    }
    
    // Asynchronous execute function to avoid blocking the main thread
    func execute() async -> [String] {
        await buildGraph()
        let rankedPhrases = await rank.execute()
        return rankedPhrases
            .sorted { $0.value > $1.value }
            .map { $0.key.text }
    }
    
    // Asynchronous buildGraph to run independently of the main thread
    private func buildGraph() async {
        let combinations = await self.phrases.combinations(length: 2)
        
        await withTaskGroup(of: Void.self) { group in
            for combo in combinations {
                group.addTask {
                    self.add(edge: combo.first!, node: combo.last!)
                }
            }
        }
    }
    
    private func add(edge pivotal: Sentence, node: Sentence) {
        let pivotalWordCount: Float = Float(pivotal.words.count)
        let nodeWordCount: Float = Float(node.words.count)
        
        // Calculate weight by co-occurrence of words between sentences
        var score: Float = Float(pivotal.words.filter { node.words.contains($0) }.count)
        score = score / (log(pivotalWordCount) + log(nodeWordCount))
        
        rank.add(edge: pivotal, to: node, weight: score)
        rank.add(edge: node, to: pivotal, weight: score)
    }
}
