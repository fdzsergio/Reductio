/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

struct Sentence: Equatable, Hashable, Sendable {
  let text: String
  let words: [String]

  init(text: String) {
    self.text = text
    self.words = Stemmer.stemmingWordsInText(text)
      .filter { !Search.binary(stopwords, target: $0) }
  }

  init(text: String, stopwords: [String] = stopwords) {
    self.text = text
    self.words = Stemmer.stemmingWordsInText(text)
      .filter { !Search.binary(stopwords, target: $0) }
  }
}
