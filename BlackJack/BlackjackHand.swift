//
//  BlackjackHand.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/10/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BlackjackHand: NSObject {
    var bet = 0.0
    var initialCardPair = false
    var doubled = false
    var split = false
    lazy var gameConfiguration = GameConfiguration()
    
    var cards: [BlackjackCard] = [] {
        didSet {
            updateHandState()
        }
    }
    enum HandState: Int {
        case Active = 1, NaturalBlackjack, Stood, Busted, Surrendered, Won, Lost, Tied
           }
    var handState: HandState = .Active {
        didSet {
            if oldValue != handState {
                println("handState is now \(handState.rawValue) was \(oldValue.rawValue)")
            }
        }
    }
    var containsAce: Bool {
        for card in self.cards {
            if card.rank.values.second != nil {
                return true
            }
        }
        return false
    }
    var rawValue: Int {
        var result = 0
        for card in self.cards {
            result += card.rank.values.first
        }
        return result
    }
    var value: Int {
        if containsAce && rawValue <= 11 {
            return rawValue + 10
        }
        return rawValue
    }

    var valueDescription: String {
        switch handState {
        case .NaturalBlackjack:
            return "Blackjack!"
        case .Busted:
            return "Busted!"
        case .Surrendered:
            return "Surrendered"
        case .Won:
            return "Won"
        case .Lost:
            return "Lost"
        case .Tied:
            return "Tied"
        case .Stood:
            fallthrough
        case .Active:
            if rawValue == value {
                return "\(value)"
            } else {
                return "Soft \(value)"
            }
        }
    }
    
    func updateHandState() {
        switch cards.count {
        case 1:
            handState = .Active
        case 2:
            if value == 21 && !doubled && !split {
                handState = .NaturalBlackjack
                break
            }
            if value == 21 && gameConfiguration.autoStandOnPlayer21 {
                handState = .Stood
                break
            }
            if cards[0].rank == cards[1].rank {
                initialCardPair = true
                break
            }
            if (cards[0].rank == BlackjackCard.Rank.Ace) && split  {
                // split aces hand is automatically stood after two cards
                handState = .Stood
            }

        case 3...15:         // you can never have more than 11 cards in any valid dealer hand, there is never a need for more than 11 cards for any reasonable player hand, but in pathological cases we can have 15 card player hand
            initialCardPair = false
            if value > 21 {
                handState = .Busted
                break
            }
            if doubled {
                handState = .Stood
            }
            if value == 21 && gameConfiguration.autoStandOnPlayer21 {
                handState = .Stood
            }
        default:
            break
        }
    }
}
