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
    var bankRoll = 0.0
    var currentBet = 0.0
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
        case Hit = 1, Stand, Split, DoubleDown, Surrender, BuyInsurance, Bet, Wager
    }
    
    var previousAction: Action?
    
    func bet(amount: Double) -> Bool {
        previousAction = .Wager
        if (bankRoll - amount) >= 0.0 {
            bankRoll -= amount
            currentBet = amount
            observer?.bankrollUpdate()
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
        insuranceAvailable = false
        surrenderOptionAvailabe = false
        if let card = delegate?.getCard() {
            addCardToCurrentHand(card)
        }
        previousAction = .Hit
        delegate?.updated(self)
    }
    
    func stand() {
        insuranceAvailable = false
        surrenderOptionAvailabe = false
        currentHand!.handState = .Stood
        previousAction = .Stand
        delegate?.updated(self)
    }
    
    func split() {
        previousAction = .Split
        insuranceAvailable = false
        surrenderOptionAvailabe = false
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
            if let card = delegate?.getCard() {
                addCardToCurrentHand(card)
            }
            // If the split hand was aces - consult game configuration and act accordingly
            if secondCard.rank == .Ace {
                println("split of aces being handled")
                advanceToNextHand()
            }
        }
    }
    
    func advanceToNextHand() {
        if currentHandIndex < hands.count - 1 {
            currentHandIndex++
            currentHand = hands[currentHandIndex]
            observer?.switchHands()
        }
    }
    
    func doubleDown() {
        previousAction = .DoubleDown
        insuranceAvailable = false
        surrenderOptionAvailabe = false
        insuranceAvailable = false
        if (bankRoll - currentBet) >= 0.0 {
            bankRoll -= currentBet
            currentHand!.bet += currentBet
            observer?.bankrollUpdate()
            if let card = delegate?.getCard() {
                currentHand!.doubled = true
                addCardToCurrentHand(card)
            }
            delegate?.updated(self)
        } else {
            println("don't have the bankroll to double down")
        }
    }
    
    func insuranceOffered() {
        insuranceAvailable = true
        surrenderOptionAvailabe = false
    }
    
    func buyInsurance() {
        println("buying insurance")
        if (bankRoll - currentBet * 0.5 ) >= 0.0 {
            bankRoll -= currentBet * 0.5
            delegate?.insured(self)
            observer?.bankrollUpdate()
        }
    }
    
    func declineInsurance() {
        println("declining insurance")
        delegate?.declinedInsurance(self)
    }
    
    func surrenderOptionOffered() {
        surrenderOptionAvailabe = true
    }
    
    func surrenderHand() {
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
