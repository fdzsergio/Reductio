/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation
import NaturalLanguage

enum Stemmer {
  static func stemmingWordsInText(_ text: String) -> [String] {
    var stems: [String] = []

    let tokenizer = NLTokenizer(unit: .word)
    tokenizer.string = text

    let tagger = NLTagger(tagSchemes: [.lemma])
    tagger.string = text

    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
      let token = String(text[tokenRange])

      if let tag = tagger.tag(at: tokenRange.lowerBound, unit: .word, scheme: .lemma).0?.rawValue {
        stems.append(tag.lowercased())
      } else {
        stems.append(token.lowercased())
      }

      return true
    }
    return stems
  }
}
