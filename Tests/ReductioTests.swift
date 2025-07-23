/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Testing

@testable import Reductio

@Suite("Reductio Tests")
struct ReductioTests {

  // MARK: This text is an extract from http://www.theverge.com/2016/3/28/11284590/oculus-rift-vr-review

  let str =
    "Oculus rarely brags about its industrial design, but one of the best things it's done is make something so stereotypically geeky look (relatively) natural. The $599 consumer Rift is full of clever and thoughtful touches, starting with the delightfully soft rubberized carrying case it ships in, which makes the whole thing feel like a cyberpunk hacker's console. The all-black headset is downright understated by gaming hardware standards, with a front of smooth rubber, sides coated in coarse cloth, and lenses surrounded by a web of lycra. It's tethered to a PC by a single wire, which runs out your left temple and along one of the adjustable side straps. William Gibson's best-known foray into virtual reality might be Neuromancer, but the Rift feels more like something from his design-obsessed novel Pattern Recognition — it's the kind of minimalist product that its brand-allergic, coolhunting protagonist Cayce Pollard might approve of. Getting the Rift to fit right can prove elusive at first. While there's a small focus knob at the bottom, a lot of the screen's clarity depends on precisely how it's angled toward your eyes, and it's easy to give yourself a headache by strapping it as tightly as possible to keep the best fit. But once you get used to wearing it, the headset feels lighter and more comfortable than most of its competition, sealing against your face with a firm but pliable ring of foam. Since I have yet to break a sweat in the Rift, I can't say how easy it is to clean, but the ring is removable and replaceable — although there's no spare included. I also don't have to deal with wearing glasses, but my Verge colleagues who do have had a positive response — they could either fit the headset over moderately-sized frames or, depending on their prescription, get the screen in focus without them. Along with a cylindrical black tracking camera on a slender 8-inch stand, the Rift comes with  two accessories: an Xbox One gamepad and a small, simple device called the Oculus Remote. Unlike Sony and HTC, Oculus isn't launching the Rift with a full controller of its own, since its Oculus Touch hardware will arrive in the second half of this year. For now, the chunky and colorful Xbox gamepad seems slightly out of place alongside the sleek Rift design. The oval-shaped black remote, by contrast, fits right in, although its construction doesn't feel as solid as the rest of the system. The Rift is something I'd be happy to have in my living room, and compared to the developer-focused Oculus devices of years past, it's a breeze to set up. The 4-meter headset tether ends with one USB and one HDMI port, and the tracking camera is plugged in with its own USB cable — there's no external power cable or controller box for either piece. You'll just download Oculus' Windows app and run through a short, though descriptive, setup checklist before getting into VR. Granted, getting to this point requires having a powerful gaming desktop, which can produce plenty of glitches on its own. And since most PCs have only one HDMI port, you'll need to use a different connection for your monitor, an extra and not totally intuitive step for many people. For the most part, though, it's as easy as I can imagine installing a totally new kind of computer hardware to be."

  @Test("Keywords extraction returns non-nil result")
  func hasKeywords() {
    let keywords = str.keywords
    #expect(keywords.count > 0)
  }

  @Test("Empty text returns empty keywords")
  func emptyTextKeywords() {
    #expect("".keywords.isEmpty)
  }

  @Test("Keywords contain expected terms")
  func textContainsKeywords() {
    let keywords = str.keywords
    #expect(keywords.contains("oculus"))
    #expect(keywords.contains("rift"))
    #expect(keywords.contains("headset"))
  }

  @Test("Async keywords match synchronous version")
  func textContainsSameKeywords() async {
    let syncKeywords = str.keywords
    let asyncKeywords = await Reductio.keywords(from: str)
    #expect(asyncKeywords == syncKeywords)
  }

  @Test("Keywords count respects limit")
  func reductioKeywordsWithCounter() async {
    let words = await Reductio.keywords(from: str, count: 5)
    #expect(words.count == 5)
  }

  @Test("Keywords compression with zero returns all")
  func reductioKeywordsWithCompression() async {
    let allKeywords = str.keywords
    let words = await Reductio.keywords(from: str, compression: 0)
    #expect(words == allKeywords)
  }

  @Test("Out of bounds compression returns empty")
  func reductioKeywordsWithOutboundsCompression() async {
    let words = await Reductio.keywords(from: str, compression: 2.0)
    #expect(words.isEmpty)
  }

  @Test("Summarize returns non-nil result")
  func hasSummarize() {
    let summary = str.summarize
    #expect(summary.count > 0)
  }

  @Test("Summary count respects limit")
  func reductioSummarizeWithCounter() async {
    let words = await Reductio.summarize(text: str, count: 5)
    #expect(words.count == 5)
  }

  @Test("Summary compression extracts single sentence")
  func reductioSummarizeWithCompression() async {
    let sentence = await Reductio.summarize(text: str, compression: 0.95)
    #expect(sentence.count == 1)
  }

  @Suite("Edge Cases")
  struct EdgeCaseTests {

    @Test("Single word text")
    func singleWordText() {
      let keywords = "Hello".keywords
      #expect(keywords.isEmpty || keywords == ["hello"])
    }

    @Test("Text with only stopwords")
    func onlyStopwords() {
      let keywords = "the and or but if".keywords
      #expect(keywords.isEmpty)
    }

    @Test("Text with special characters")
    func specialCharacters() {
      let keywords = "Hello!@#$%^&*()World".keywords
      #expect(keywords.contains("hello") || keywords.contains("world"))
    }

    @Test("Very long text performance")
    func performanceTest() async {
      let longText = String(repeating: "This is a test sentence with various words. ", count: 1000)
      let keywords = await Reductio.keywords(from: longText, count: 10)
      #expect(keywords.count <= 10)
    }
  }

  @Suite("Value Type Behavior")
  struct ValueTypeTests {

    @Test("Keyword struct is value type")
    func keywordValueSemantics() {
      let text = "Test text for keyword extraction"
      let keyword1 = Keyword(text: text)
      let keyword2 = keyword1

      // Both should produce same results since they're independent values
      let results1 = keyword1.execute()
      let results2 = keyword2.execute()

      // Since ordering might vary due to dictionary iteration, check set equality
      #expect(Set(results1) == Set(results2))
      #expect(results1.count == results2.count)
    }

    @Test("Summarizer struct is value type")
    func summarizerValueSemantics() {
      let text = "First sentence. Second sentence. Third sentence."
      let summarizer1 = Summarizer(text: text)
      let summarizer2 = summarizer1

      // Both should produce same results since they're independent values
      let results1 = summarizer1.execute()
      let results2 = summarizer2.execute()

      // Since ordering might vary due to dictionary iteration, check set equality
      #expect(Set(results1) == Set(results2))
      #expect(results1.count == results2.count)
    }
  }
}
