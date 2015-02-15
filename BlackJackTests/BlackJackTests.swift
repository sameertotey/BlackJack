//
//  BlackJackTests.swift
//  BlackJackTests
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import XCTest

extension BlackjackCardShoe {
    func newShoe(cards: [BlackjackCard]) {
        self.cards = cards
    }
}

class BlackJackTests: XCTestCase {
    var blackjackGame: BlackjackGame!
    var currentPlayer: Player!
    var gameConfiguraton: GameConfiguration!
    var theDealer: Dealer!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        /*
        class PlayerObserver: CardPlayerObserver {
            func currentHandStatus(value: String)
 {println("you are at \(__FUNCTION__)")}
            func addCardToCurrentHand(card: BlackjackCard) {println("you are at \(__FUNCTION__)")}
            func addnewlySplitHand(card: BlackjackCard) {println("you are at \(__FUNCTION__)")}
            func switchHands() {println("you are at \(__FUNCTION__)")}
        }
        
        class TheDealerObserver: DealerObserver {
            func currentDealerHandValue(value: String) {println("you are at \(__FUNCTION__)")}
            func flipHoleCard() {println("you are at \(__FUNCTION__)")}
            func addCardToDealerHand(card: BlackjackCard) {println("you are at \(__FUNCTION__)")}
            func updateBankRoll() {println("you are at \(__FUNCTION__)")}
        }

       */

        gameConfiguraton = GameConfiguration()
        blackjackGame = BlackjackGame()
        blackjackGame.gameConfiguration = gameConfiguraton
        currentPlayer = Player(name: "Sameer")
//        currentPlayer.observer = PlayerObserver()
        currentPlayer.bankRoll = 100.00
        currentPlayer.delegate = blackjackGame
        theDealer = Dealer()
//        theDealer.observer = TheDealerObserver()
        blackjackGame.dealer = theDealer

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
        let cards = [BlackjackCard(rank: .Ace, suit: .Spades), BlackjackCard(rank: .Ace, suit: .Spades), BlackjackCard(rank: .Ace, suit: .Spades), BlackjackCard(rank: .Ace, suit: .Spades), BlackjackCard(rank: .Ace, suit: .Spades), BlackjackCard(rank: .Ace, suit: .Spades), BlackjackCard(rank: .Ace, suit: .Spades)]
        
        XCTAssert(blackjackGame.cardShoe.cards.count == 0, "There are not 0 cards")

        blackjackGame.cardShoe.newShoe(cards)
        
        XCTAssert(blackjackGame.cardShoe.cards.count == 7, "There are not 7 cards")
        
        blackjackGame.deal()
        
        XCTAssert(theDealer.hand!.cards.count == 2, "The dealer hand has two cards")
        XCTAssert(currentPlayer.hands[0].cards.count == 2, "The player hand1 has two cards")
        
        currentPlayer.split()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
