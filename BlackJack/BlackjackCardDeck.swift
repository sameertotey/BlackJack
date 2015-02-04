//
//  BlackjackCardDeck.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BlackjackCardDeck: NSObject {
     let cards: [BlackjackCard]
    
    override init() {
        self.cards = []
        for rawSuit in BlackjackCard.Suit.allSuits  {
            for var rawRank = 2; rawRank <= 14; rawRank++ {
                self.cards.append(BlackjackCard(rank: BlackjackCard.Rank(rawValue: rawRank)!, suit: BlackjackCard.Suit(rawValue: rawSuit)!))
            }
        }
    }
    
}
