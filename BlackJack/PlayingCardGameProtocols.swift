//
//  PlayingCardGameProtocols.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/8/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

protocol PlayingCardGame: CardDataSource {
    var gameConfiguration: GameConfiguration {get}
    func play()
    func update()
}

protocol PlayingGameDelegate {
    func gameDidStart(game: PlayingCardGame)
    func game(game: PlayingCardGame, didStartNewHand hand: Int)
    func gameDidEnd(game: PlayingCardGame)
}

protocol CardPlayerDelegate: class {
    func registerPlayer(player: Player)
    func updated(player: Player)
    func getCard() -> BlackjackCard
    func insured(player: Player)
    func declinedInsurance(player: Player)
}
    
protocol CardPlayerObserver: class {
    func currentHandStatusUpdate(hand: BlackjackHand)
    func addCardToCurrentHand(card: BlackjackCard)
    func addnewlySplitHand(card: BlackjackCard)
    func switchHands()
}

protocol DealerObserver: class {
    func currentDealerHandUpdate(hand: BlackjackHand)
    func flipHoleCard()
    func addCardToDealerHand(card: BlackjackCard)
    func addUpCardToDealerHand(card: BlackjackCard)
    func addHoleCardToDealerHand(card: BlackjackCard)
    func gameCompleted()
}

protocol BlackjackGameDelegate: class {
}

protocol CardDataSource: class {
    func drawACard() -> BlackjackCard
}

