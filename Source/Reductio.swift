/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */
import Foundation

/**
 Extract all keywords from text sorted by relevance
 
 - parameter text: Text to extract keywords.
 
 - returns: sorted keywords from text
 
 */
public func keywords(from text: String) async -> [String] {
    return await text.keywords
}

/**
 Extract first keywords from text sorted by relevance
 
 - parameter text: Text to extract keywords.
 - parameter count: Number of keywords to extract.
 
 - returns: sorted keywords from text
 
 */
public func keywords(from text: String, count: Int) async -> [String] {
    return await text.keywords.slice(length: count)
}

/**
 Extract keywords from text sorted by relevance with a rate of compression
 
 - parameter text: Text to extract keywords.
 - parameter compression: Ratio of compression to extract keywords. From 0..<1.
 
 - returns: sorted keywords from text
 
 */
public func keywords(from text: String, compression: Float) async -> [String] {
    return await text.keywords.slice(percent: compression)
}

/**
 Reordered text phrases by relevance on text
 
 - parameter text: Text to summarize.
 
 - returns: sorted phrases from text
 
 */
public func summarize(text: String) async -> [String] {
    return await text.summarize
}

/**
 Reordered text phrases by relevance on text
 
 - parameter text: Text to summarize.
 - parameter count: Number of phrases to extract.
 
 - returns: sorted phrases from text
 
 */
public func summarize(text: String, count: Int) async -> [String] {
    return await text.summarize.slice(length: count)
}

/**
 Reordered text phrases by relevance on text
 
 - parameter text: Text to summarize.
 - parameter compression: Ratio of compression to extract phrases. From 0..<1.
 
 - returns: sorted phrases from text
 
 */
public func summarize(text: String, compression: Float) async -> [String] {
    return await text.summarize.slice(percent: compression)
}

public extension String {
    
    /**
     Extract all keywords from text sorted by relevance
     
     - returns: sorted keywords from text
     
     */
    var keywords: [String] {
        get async {
            return await Keyword(text: self).execute()
        }
    }
    
    /**
     Reordered text phrases by relevance on text
     
     - returns: sorted phrases from text
     
     */
    var summarize: [String] {
        get async {
            return await Summarizer(text: self).execute()
        }
    }
}
