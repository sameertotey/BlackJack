//
//  Player.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation


class Player: NSObject {
    var name: String?
    dynamic var bankRoll = 0.0
    var currentBet = 0.0
    var gameConfiguration: GameConfiguration?
    var insuranceAvailable: Bool = false {
        didSet {
            if insuranceAvailable == true {
                surrenderOptionAvailabe = false
            }
        }
    }
    var surrenderOptionAvailabe: Bool = false
    var hands = [BlackjackHand]()
    var currentHand: BlackjackHand?
    var currentHandIndex = 0
    
    weak var delegate: CardPlayerDelegate? {
        didSet {
            delegate?.registerPlayer(self)
        }
    }
    
    var observer: CardPlayerObserver?
    enum Action: Int {
        case Hit = 1, Stand, Split, DoubleDown, Surrender, BuyInsurance, DeclineInsurance, Bet, Wager
    }
    
    var previousAction: Action = .Wager
    
    func bet(amount: Double) -> Bool {
        previousAction = .Wager
        if (bankRoll - amount) >= 0.0 {
            bankRoll -= amount
            return true
        }
        return false
    }
    
    func createNewCurrentHand() {
        previousAction = .Bet
        hands = []
        currentHandIndex = 0
        currentHand = BlackjackHand()
        currentHand!.bet = currentBet
        hands.append(currentHand!)
    }
    
    func addCardToCurrentHand(card: BlackjackCard) {
        currentHand!.cards.append(card)
        observer?.addCardToCurrentHand(card)
        observer?.currentHandStatusUpdate(currentHand!)
    }
    
    func hit() {
        surrenderOptionAvailabe = false
        if insuranceAvailable {
            // implied rejection of insurance
            declineInsurance()
        }
        if currentHand!.handState == .Active {
            if let card = delegate?.getCard() {
                println("Player hit for the card \(card)")
                addCardToCurrentHand(card)
            }
        }
        previousAction = .Hit
        delegate?.updated(self)
    }
    
    func stand() {
        surrenderOptionAvailabe = false
        if insuranceAvailable {
            // implied rejection of insurance
            declineInsurance()
        }
        if currentHand!.handState == .Active {
            currentHand!.handState = .Stood
        }
        previousAction = .Stand
        delegate?.updated(self)
    }
    
    func split() {
        surrenderOptionAvailabe = false
        if insuranceAvailable {
            // implied rejection of insurance
            declineInsurance()
        }
        if currentHand!.handState == .Active {
            if (bankRoll - currentBet) >= 0.0 {
                bankRoll -= currentBet
                var newHand = BlackjackHand()
                newHand.bet = currentBet
                var secondCard = currentHand!.cards.removeLast()
                currentHand!.initialCardPair = false
                newHand.cards.append(secondCard)
                newHand.split = true
                currentHand!.split = true
                hands.append(newHand)
                observer?.addnewlySplitHand(secondCard)
                sendNotification("Splitting the Hand")
                if let card = delegate?.getCard() {
                    addCardToCurrentHand(card)
                }
                // If the split hand was aces - consult game configuration and act accordingly
                if secondCard.rank == .Ace {
                    if gameConfiguration != nil {
                        if gameConfiguration!.onlyOneCardOnSplitAces {
                            println("split of aces being handled")
                            sendNotification("Split Aces")
                            advanceToNextHand()
                        }
                    }
                }
                // If the hand state is not active advance to next hand??
                if currentHand!.handState == .Stood {
                    println("Advancing to next hand")
                    sendNotification("Auto stand on 21")
                    advanceToNextHand()
                }
            } else {
                sendNotification("Cannot Split - not enough bankroll")
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.playerLabelDisplayed, object: nil)
            }
        }
        previousAction = .Split
    }
    
    func advanceToNextHand() {
        if currentHandIndex < hands.count - 1 {
            currentHandIndex++
            currentHand = hands[currentHandIndex]
            observer?.switchHands()
            sendNotification("Moving to the next split hand")
        }
    }
    
    func doubleDown() {
        surrenderOptionAvailabe = false
        if insuranceAvailable {
            // implied rejection of insurance
            declineInsurance()
        }
        if currentHand!.handState == .Active {
            if (bankRoll - currentBet) >= 0.0 {
                bankRoll -= currentBet
                currentHand!.bet += currentBet
                if let card = delegate?.getCard() {
                    currentHand!.doubled = true
                    addCardToCurrentHand(card)
                }
                delegate?.updated(self)
                sendNotification("Doubled your bet")
            } else {
                sendNotification("Cannot Double - not enough bankroll")
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.playerLabelDisplayed, object: nil)
                println("don't have the bankroll to double down")
            }
        }
        previousAction = .DoubleDown

    }
    
    func insuranceOffered() {
        insuranceAvailable = true
        surrenderOptionAvailabe = false
    }
    
    func buyInsurance() {
        println("buying insurance")
        previousAction = .BuyInsurance
        if (bankRoll - currentBet * 0.5 ) >= 0.0 {
            bankRoll -= currentBet * 0.5
            delegate?.insured(self)
            sendNotification("Insurance bet made")
        }
    }
    
    func declineInsurance() {
        println("declining insurance")
        sendNotification("Insurance declined")
        previousAction = .DeclineInsurance
        delegate?.declinedInsurance(self)
        delegate?.updated(self)
    }
    
    func surrenderOptionOffered() {
        surrenderOptionAvailabe = true
    }
    
    func sendNotification(message: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.setStatus, object: message)
    }
    

    func surrenderHand() {
        sendNotification("Surrendered the bet")
        previousAction = .Surrender
        currentHand!.handState = .Surrendered
        delegate?.updated(self)
    }
    
    override init() {
        super.init()
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
        delegate?.registerPlayer(self)
    }
}
