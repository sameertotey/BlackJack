//
//  BlackjackCardDeck.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit


func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
    let count = countElements(list)
    for i in 0..<(count - 1) {
        let j = Int(arc4random_uniform(UInt32(count - i))) + i
        swap(&list[i], &list[j])
    }
    return list
}

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension Array {
    func shuffled() -> [T] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
}

class PlayingCardDeck<T: PlayingCard>: NSObject {
     let cards: [T]
    
    override init() {
        self.cards = []
        for rawSuit in T.Suit.allSuits  {
            for var rawRank = 2; rawRank <= 14; rawRank++ {
                self.cards.append(T(rank: T.Rank(rawValue: rawRank)!, suit: T.Suit(rawValue: rawSuit)!))
            }
            
        }
    }
    
}
