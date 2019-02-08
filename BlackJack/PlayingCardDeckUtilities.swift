//
//  PlayingCardDeckUtilities.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

//
// Util delay function
//
func delay(seconds: Double, completion:@escaping ()->Void) {
//    let popTime = dispatch_time(dispatch_time_t(DispatchTime.now()), Int64( Double(NSEC_PER_SEC) * seconds ))
//
//    dispatch_after(popTime, dispatch_get_main_queue()) {
//        completion()
//    }
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
    let numElements = count(list)
    for i in 0..<(numElements - 1) {
        let j = Int(arc4random_uniform(UInt32(numElements - i))) + i
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
    var cards: [T]
    
    override init() {
        self.cards = []
        for rawSuit in T.Suit.allSuits  {
            for var rawRank = 2; rawRank <= 14; rawRank++ {
                self.cards.append(T(rank: T.Rank(rawValue: rawRank)!, suit: T.Suit(rawValue: rawSuit)!))
            }
            
        }
    }
    
}
