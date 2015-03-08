//
//  BlackjackCardShoe.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/7/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation


class BlackjackCardShoe: NSObject {
    var cards: [BlackjackCard] {
        didSet {
            sendNotification()
            }
    }
    var initialCount: Int = 0
    override init() {
        cards = []
        super.init()
    }
    
    convenience init(numDecks: Int) {
        self.init()
        assert(numDecks > 0, "The Shoe needs atleast one deck of cards")
        let cardsInBlackJackDeck: [BlackjackCard] = PlayingCardDeck().cards
        for _ in 0..<numDecks {
           cards += cardsInBlackJackDeck
        }
        cards.shuffle()
    }
    
    func newShoe(numDecks: Int) {
        assert(numDecks > 0, "The Shoe needs atleast one deck of cards")
        cards = []
        let cardsInBlackJackDeck: [BlackjackCard] = PlayingCardDeck().cards
        for _ in 0..<numDecks {
            cards += cardsInBlackJackDeck
        }
        initialCount = cards.count
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
    
    func sendNotification() {
        let contentStatus = Float(initialCount - cards.count) / Float(initialCount)
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.cardShoeContentStatus, object: contentStatus)
    }
}
