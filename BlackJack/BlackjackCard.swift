//
//  BlackjackCard.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BlackjackCard: NSObject {
    // nested Suit enumeration
    enum Suit: String {
        case Spades = "♠️", Hearts = "♥️", Diamonds = "♦️", Clubs = "♣️"
        
        static let allSuits = ["♠️", "♥️", "♦️", "♣️"]
    }
    
    // nested Rank enumeration
    enum Rank: Int {
        case Two = 2, Three, Four, Five, Six, Seven, Eight, Nine, Ten
        case Jack, Queen, King, Ace
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
        var shortDescription: String {
            switch self {
            case .Ace:
                return "A"
            case .Jack:
                return "J"
            case .Queen:
                return "Q"
            case .King:
                return "K"
            default:
                return "\(rawValue)"
            }
            
        }
    }
    
    // BlackjackCard properties and methods
    let rank: Rank, suit: Suit
    override var description: String {
        var output = "suit is \(suit.rawValue),"
        switch rank {
        case .Two:
            output += " rank is Two,"
        case .Three:
            output += " rank is Three,"
        case .Four:
            output += " rank is Four"
        case .Five:
            output += " rank is Five"
        case .Six:
            output += " rank is Six"
        case .Seven:
            output += " rank is Seven"
        case .Eight:
            output += " rank is Eight"
        case .Nine:
            output += " rank is Nine"
        case .Ten:
            output += " rank is Ten"
        case .Jack:
            output += " rank is Jack"
        case .Queen:
            output += " rank is Queen"
        case .King:
            output += " rank is King"
        case .Ace:
            output += " rank is Ace"
        }
        output += " value is \(rank.values.first)"
        if let second = rank.values.second {
            output += " or \(second)"
        }
        return output
    }
    
    init (rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
        super.init()
    }
}
