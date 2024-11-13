/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal struct Sentence {
    
    let text: String
    let words: [String]
    
    // Asynchronous factory method for creating a Sentence
    static func create(text: String, stopwords: [String] = stopwords) async -> Sentence {
        let stemmedWords = await Stemmer.stemmingWordsInText(text)
        var filteredWords: [String] = []
        
        for word in stemmedWords {
            if await !Search.binary(stopwords, target: word) {
                filteredWords.append(word)
            }
        }
        
        return Sentence(text: text, words: filteredWords)
    }

    
    // Private initializer to be used by the async factory method
    internal init(text: String, words: [String]) {
        self.text = text
        self.words = words
    }
}

extension Sentence: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    public static func == (lhs: Sentence, rhs: Sentence) -> Bool {
        return lhs.text == rhs.text
    }
}

internal extension String {
    
    var sentences: [String] {
        var sentences = [String]()
        let range = self.startIndex..<self.endIndex
        
        self.enumerateSubstrings(in: range, options: .bySentences) { substring, _, _, _ in
            if let substring = substring {
                sentences.append(substring)
            }
        }
        return sentences
    }
}
