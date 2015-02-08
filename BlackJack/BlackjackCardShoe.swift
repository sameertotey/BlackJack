//
//  BlackjackCardShoe.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/7/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BlackjackCardShoe: NSObject {
    var cards: [BlackjackCard]
    
    override init() {
        cards = []
        super.init()
    }
    
    convenience init(numDecks: Int) {
        self.init()
        assert(numDecks > 0, "The Shoe needs atleast one deck of cards")
        let cardsInBlackJackDeck = BlackjackCardDeck().cards
        for _ in 0..<numDecks {
           cards += cardsInBlackJackDeck
        }
        cards.shuffle()
    }
    
    func drawCardFromTop() -> BlackjackCard? {
        if !cards.isEmpty {
            return cards.removeLast()
        }
        return nil
    }
    
    func drawCardAt(index: Int) -> BlackjackCard? {
        if cards.count > index {
            return cards.removeAtIndex(index)
        }
        return nil
    }
    
    func drawRandomCard() -> BlackjackCard? {
        return drawCardAt(Int(arc4random_uniform(UInt32(cards.count))))
    }
}
