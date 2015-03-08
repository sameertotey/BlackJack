//
//  Dealer.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

class Dealer: NSObject {
    var bankRoll = 1000_0000.00
    var hand: BlackjackHand?  // Dealer has only one hand at any given time
    weak var observer: DealerObserver?
    var insuranceOffered = false  // Insurance in an independent bet from the player hand
    var gameConfiguration: GameConfiguration?
    weak var cardSource: CardDataSource?
    var upCard: BlackjackCard!
    var holeCard: BlackjackCard!
    
    func deal(players: [Player]) {
        println("Dealing")
        self.hand = BlackjackHand()
        for i in 0...1 {
            for player in players {
                if i == 0 {
                    player.createNewCurrentHand()
                }
                let card = cardSource!.drawACard()
                player.addCardToCurrentHand(card)
            }
            let card = cardSource!.drawACard()
            if i == 0 {
                upCard = card
                self.hand!.cards.append(card)
                observer?.addUpCardToDealerHand(card)
            } else {
                holeCard = card
                self.hand!.cards.append(card)
                observer?.addHoleCardToDealerHand(card)
            }
        }
        if hand!.handState != .NaturalBlackjack {
            offerSurrender(players)
        }
        if upCard.rank.values.first == 10 {
            checkForDealerBlackjack(players)
        } else if upCard.rank == .Ace {
            offerInsurance(players)
        }
     }
    
    func sendNotification(message: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.setStatus, object: message)
    }

    func checkForDealerBlackjack(players: [Player]) {
        println("Checking For Dealer Blackjack")
        // if we have no hole card rule in game options then we should skip this step
        if gameConfiguration!.checkHoleCardForDealerBlackJack {
            if hand!.handState == .NaturalBlackjack {
                println("Dealer has a blackjack, sorry players")
                sendNotification("Dealer Blackjack!")
                // we have to have special payout here
                for player in players {
                    switch player.currentHand!.handState {
                    case .NaturalBlackjack:
                        player.currentHand!.handState = .Tied
                    default:
                        player.currentHand!.handState = .Lost
                    }
                }
            }
        }
    }
    
    func offerInsurance(players: [Player]) {
        if gameConfiguration!.insuranceAllowed {
            sendNotification("Insurance offerred")
            println("Offering Insurance for players")
            insuranceOffered = true
            for player in players {
                player.insuranceOffered()
            }
        }
    }
    
    func offerSurrender(players: [Player]) {
        // Check game configuration if surrender is allowed and if insurance is not active.....
        if gameConfiguration!.surrenderAllowed {
//            println("Offering surrender option to players")
//            sendNotification("Surrender option offered")
            for player in players {
                player.surrenderOptionOffered()
            }
        }
    }

    func payout(players: [Player]) {
        for player in players {
            for hand in player.hands {
                switch hand.handState {
                case .Active:
                    println("This is an error, player's hand can't be active now")
                case .NaturalBlackjack:
                    println("The winning blackjack hand paid \(hand.bet * gameConfiguration!.multipleForPlayerBlackjack)")
//                    sendNotification("Blackjack paid \(hand.bet * gameConfiguration!.multipleForPlayerBlackjack)")
                    let winning = hand.bet + hand.bet * gameConfiguration!.multipleForPlayerBlackjack
                    player.bankRoll += winning
                    hand.bet = 0
                case .Stood:
                    if self.hand!.handState != .Busted {
                        if hand.value == self.hand!.value {
                            hand.handState = .Tied
                            // returning the bet to the player
                            player.bankRoll += hand.bet
                        } else if hand.value < self.hand!.value {
                            hand.handState = .Lost
                        } else {
                            hand.handState = .Won
                            let winning = hand.bet * 2
                            player.bankRoll += winning
                        }
                    } else {
                        hand.handState = .Won
                        let winning = hand.bet * 2
                        player.bankRoll += winning
                    }
                    hand.bet = 0
                case .Busted:
                    hand.handState = .Lost
                    hand.bet = 0
                    println("The player lost")
                case .Surrendered:
//                    hand.handState = .Lost
                    // return half the bet back (depending on the rule in gameConfiguration
                    let surrenderAllowance = hand.bet / 2
                    player.bankRoll += surrenderAllowance
                    hand.bet = 0
                case .Won:
                    println("This is an error, player's hand can't be won now")
                case .Lost:
                    // this only happens on the initial dealer blackjack with hole card
                    hand.bet = 0
                case .Tied:
                    // returning the bet to the player, this only happens on initial blackjacks by both the player and dealer on the hole card
                    player.bankRoll += hand.bet
                    hand.bet = 0
                }
            }
        }
    }
    
    func flipHoleCard() {
        observer?.flipHoleCard()
    }
    
    func evaluateHand() {
        // read the hit on soft 17 setting from gameConfiguraion
        if (hand!.handState == .Active) {
            if gameConfiguration!.dealerMustHitSoft17 {
                if hand!.value >= 18 || ((hand!.value == hand!.rawValue) && hand!.value >= 17) {
                    hand!.handState = .Stood
                }
            } else {
                if hand!.value >= 17 {
                    hand!.handState = .Stood
                }
            }
        }
        observer?.currentDealerHandUpdate(hand!)
    }
    
    func completeGame(players: [Player]) {
        flipHoleCard()
        evaluateHand()
        
        if checkNeedToComplete(players) {
            completePlay()
        }
        
        payout(players)
        observer?.gameCompleted()
    }
    
    func completePlay() {
        while hand!.handState == .Active {
            let card = cardSource!.drawACard()
            hand!.cards.append(card)
            evaluateHand()
            observer?.addCardToDealerHand(card)
        }
    }
    func checkNeedToComplete(players: [Player]) -> Bool {
        // If there is no active hand for any player, there is no need to continue dealer play
        for player in players {
            for hand in player.hands {
                if hand.handState == .Stood {
                    return true
                }
            }
        }
        return false
    }
}
