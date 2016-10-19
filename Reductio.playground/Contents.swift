//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

import Reductio

// MARK: This text is an extract from http://www.theverge.com/2016/3/28/11284590/oculus-rift-vr-review

var text = "Tony Abbott maintains he never made a deal with a crossbench senator to change gun laws, insisting it was his government that stopped the guns. Key crossbench senator David Leyonhjelm claims the Abbott government made an agreement with his office to insert a sunset clause of 12 months on the importation of the Adler lever-action shotgun.But the former prime minister says every piece of legislation has a sunset clause and letters purporting of such a deal was about telling Senator Leyonhjelm what was happening anyway.No deals from me. No deals from my office. No deal, he told ABC's 730 program on Wednesday.These guns were stopped because of his government, he said.But for the Abbott government we would now have tens of thousands of these weapons in this country, Mr Abbott said.The Abbott government stopped them.Earlier, the former prime minister said no serious coalition government would allow rapid-fire weapons into Australia as he responded to calls within the coalition for the Adler to be allowed to be imported.With a heightened terror threat there is just no way that any serious coalition government, any government in the tradition of John Howard, should be allowing rapid-fire weapons on a very large scale into our country, he told reporters in Canberra.Tight gun controls were one of the reasons Australia had avoided mass casualty events. If you allow rapid-fire guns into the country under relatively loose conditions you obviously raise the danger that people who want to do us harm will get access to them, he said.Asked whether the Turnbull government should rule out issuing any import permits for the Adler weapon, Mr Abbott said it should do whatever it needed to do to ensure that rapid-fire guns were not readily available in this country.This idea that shooters generally should have access to rapid-fire weapons is just crackers and it should never happen as far as I'm concerned.Asked about Mr Abbott's comments in parliament, Prime Minister Malcolm Turnbull said his government would never weaken Australia's gun laws.Mr Turnbull attacked Labor leader Bill Shorten, who asked the question, over his opposition to mandatory sentencing for convicted gun smugglers. Let's call that smugglers' cove over there, Mr Turnbull said, pointing to the opposition benches.All he needs is a parrot and he could be a pirate.Labor has written to the prime minister offering support for 20-year jail sentences for gun traffickers, up from the current 10 years.Mr Shorten said in the letter to Mr Turnbull there was no convincing evidence of mandatory sentencing being an effective deterrent in any area of criminal justice.However, Labor would be willing to back new government laws if mandatory sentencing was removed and the 20-year maximum sentence included.The opposition leader also sought an assurance current gun laws would not be watered down."

Reductio.keywords(text, count: 5) { words in
    print(words)
}

Reductio.summarize(text, compression: 0.8) { phrases in
    print(phrases)
}