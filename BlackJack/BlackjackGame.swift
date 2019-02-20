//
//  BlackjackGame.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation


class BlackjackGame: NSObject, PlayingCardGame, CardPlayerDelegate {
    var gameConfiguration = GameConfiguration()
    var delegate: PlayingGameDelegate?
    enum GameState: Int {
        case Reset = 1, Deal, Players, Dealer
    }
    
    var gameState: GameState = .Reset
    var players =  [Player]()
    var dealer: Dealer?
    var currentPlayer: Player?
    let cardShoe = BlackjackCardShoe()
    
    func play() {
        delegate?.gameDidStart(game: self)
//        println("Playing Blackjack")
        switch gameState {
        case .Reset:
            getNewShoe()
        default:
            print("default")
        }
    }
    
    func deal() {
        dealer?.deal(players: players)
        gameState = .Players
    }
    
    func getNewShoe() {
//        println("reseted the show")
        sendNotification(message: "New Card Shoe")
        cardShoe.newShoe(numDecks: gameConfiguration.numDecks)
        gameState = .Deal
    }
    
    func update() {
        if checkDealerTurn() {
            gameState = .Dealer
            dealer?.completeGame(players: players)
            gameState = .Reset
//            println("Cards remaining = \(cardShoe.cards.count)")
            if Double(cardShoe.cards.count) / Double(cardShoe.initialCount) > Double(gameConfiguration.redealThreshold) / 100.0 {
                gameState = .Deal
            } else {
//                println("need to shuffle here....")
                sendNotification(message: "Dealer needs to shuffle a new shoe")
                getNewShoe()
            }
        } else  {
            advanceCurrentPlayerHand()
        }
    }
    
    func checkDealerTurn() -> Bool {
        for player in players {
            for hand in player.hands {
                if hand.handState == .Active {
                    return false
                }
            }
        }
        return true
    }
    
    func advanceCurrentPlayerHand() {
        if let currentHandState = currentPlayer?.currentHand?.handState {
            if currentHandState == .Stood || currentHandState == .Busted {
//                println("hands are \(currentPlayer!.hands)")
                currentPlayer!.advanceToNextHand()
            }
        }
    }
    
    func registerPlayer(player: Player) {
        players.append(player)
        // we only have single player for now
        currentPlayer = player
    }
    
    func updated(player: Player) {
        update()
    }
    
    func getCard() -> BlackjackCard {
        return cardShoe.drawCardFromTop()!
    }
    
    func insured(player: Player) {
        player.insuranceAvailable = false
        if dealer!.hand!.handState == .NaturalBlackjack {
            player.bankRoll += 1.5 * player.currentBet
//            println("Insurance paid off..")
            sendNotification(message: "Insurance bet paid")
            switch player.currentHand!.handState {
            case .NaturalBlackjack:
                player.currentHand!.handState = .Tied
            default:
                player.currentHand!.handState = .Lost
            }
            update()
        }
    }
    
    func declinedInsurance(player: Player) {
        player.insuranceAvailable = false
        if dealer!.hand!.handState != .NaturalBlackjack {
            if gameConfiguration.surrenderAllowed {
                player.surrenderOptionAvailabe = true
            }
        } else {
            switch player.currentHand!.handState {
            case .NaturalBlackjack:
                player.currentHand!.handState = .Tied
            default:
                player.currentHand!.handState = .Lost
            }
//            update()
            sendNotification(message: "Dealer Blackjack")
        }
    }

    func sendNotification(message: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationMessages.setStatus), object: message)
    }

    func drawACard() -> BlackjackCard {
        let card = cardShoe.drawCardFromTop()
        return card!
    }

}
