//
//  BlackjackCard.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

// Playing Card Rank enumeration extension
extension PlayingCard.Rank {
    struct Values {
        let first: Int, second: Int?
    }
    var values: Values {
        switch self {
        case .Ace:
            return Values(first: 1, second: 11)
        case .Jack, .Queen, .King:
            return Values(first: 10, second: nil)
        default:
            return Values(first: self.rawValue, second: nil)
        }
    }
}

class BlackjackCard: PlayingCard {
    
    // BlackjackCard properties and methods
    override var description: String {
        var output = super.description
        output += ", value is \(rank.values.first)"
        if let second = rank.values.second {
            output += " or \(second)"
        }
        return output
    }
    
    required init (rank: Rank, suit: Suit) {
        super.init(rank: rank, suit: suit)
    }
}
