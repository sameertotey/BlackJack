//
//  GameConfiguration.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

class GameConfiguration: NSObject {
    // we use the key constants to store value in NSUserDefaults
    let numDecksKey = "NumberOfDecks"
    let redealThresholdKey = "RedealThresholdKey"
    let multipleForPlayerBlackjackKey = "MultipleForPlayerBlackjackKey"
    let splitsAllowedKey = "SplitsAllowedKey"
    let canSplitAcesKey = "canSplitAcesKey"
    let onlyOneCardOnSplitAcesKey = "onlyOneCardOnSplitAcesKey"
    let canSplitAny10CardsKey = "canSplitAny10CardsKey"
    let maxHandsWithSplitsKey = "maxHandsWithSplitsKey"
    let doublingDownAllowedKey = "DoublingDownAllowedKey"
    let doublingDownAllowedOn10and11OnlyKey = "doublingDownAllowedOn10and11OnlyKey"
    let doublingDownAllowedOn9and10and11OnlyKey = "doublingDownAllowedOn9and10and11OnlyKey"
    let insuranceAllowedKey = "InsuranceAllowedKey"
    let surrenderAllowedKey = "SurrenderAllowedKey"
    let checkHoleCardForDealerBlackJackKey = "checkHoleCardForDealerBlackJackKey"
    let dealerMustHitSoft17Key = "dealerMustHitSoft17Key"
    let minimumBetKey = "MinimumBetKey"
    let maximumBetKey = "MaximumBetKey"
    let maxPlayersKey = "MaxPlayersKey"
    let autoStandOnPlayer21Key = "autoStandOnPlayer21Key"
    let autoWagerPreviousBetKey = "autoWagerPreviousBetKey"
    let enableSoundEffectsKey = "enableSoundEffectsKey"
    
    var numDecks = 6
    var redealThreshold = 25
    var multipleForPlayerBlackjack = 1.5
    var splitsAllowed = true
    var canSplitAces = true
    var onlyOneCardOnSplitAces = true
    var canSplitAny10Cards = false
    var maxHandsWithSplits = 4
    var doublingDownAllowed = true
    var doublingDownAllowedOn10and11Only = false
    var doublingDownAllowedOn9and10and11Only = false
    var insuranceAllowed = true
    var surrenderAllowed = false
    var checkHoleCardForDealerBlackJack = true
    var dealerMustHitSoft17 = true
    var minimumBet = 5.0
    var maximumBet = 100.0
    var maxPlayers = 1
    var autoStandOnPlayer21 = true
    var autoWagerPreviousBet = true
    var enableSoundEffects = true
    
    override init() {
        let defaults = UserDefaults.standard
        numDecks = defaults.integer(forKey: numDecksKey)
        if  numDecks == 0 {
            numDecks = 6
        }
        redealThreshold = defaults.integer(forKey: redealThresholdKey)
        if redealThreshold == 0 {
            redealThreshold = 25
        }
        multipleForPlayerBlackjack = defaults.double(forKey: multipleForPlayerBlackjackKey)
        if multipleForPlayerBlackjack == 0 {
            multipleForPlayerBlackjack = 1.5
        }
        if let _ = defaults.object(forKey: splitsAllowedKey) {
            splitsAllowed = defaults.bool(forKey: splitsAllowedKey)
        } else {
            splitsAllowed = true
        }
        if let _ = defaults.object(forKey: canSplitAcesKey) {
            canSplitAces = defaults.bool(forKey: canSplitAcesKey)
        } else {
            canSplitAces = true
        }
        if let _ = defaults.object(forKey: onlyOneCardOnSplitAcesKey) {
            onlyOneCardOnSplitAces = defaults.bool(forKey: onlyOneCardOnSplitAcesKey)
        } else {
            onlyOneCardOnSplitAces = true
        }
        if let _ = defaults.object(forKey: canSplitAny10CardsKey) {
            canSplitAny10Cards = defaults.bool(forKey: canSplitAny10CardsKey)
        } else {
            canSplitAny10Cards = false
        }
        maxHandsWithSplits = defaults.integer(forKey: maxHandsWithSplitsKey)
        if maxHandsWithSplits == 0 {
            maxHandsWithSplits = 4
        }
        if let _ = defaults.object(forKey: doublingDownAllowedKey) {
            doublingDownAllowed = defaults.bool(forKey: doublingDownAllowedKey)
        } else {
            doublingDownAllowed = true
        }
        if let _ = defaults.object(forKey: doublingDownAllowedOn10and11OnlyKey) {
            doublingDownAllowedOn10and11Only = defaults.bool(forKey: doublingDownAllowedOn10and11OnlyKey)
        } else {
            doublingDownAllowedOn10and11Only = false
        }
        if let _ = defaults.object(forKey: doublingDownAllowedOn9and10and11OnlyKey) {
            doublingDownAllowedOn9and10and11Only = defaults.bool(forKey: doublingDownAllowedOn9and10and11OnlyKey)
        } else {
            doublingDownAllowedOn9and10and11Only = false
        }
        if let _ = defaults.object(forKey: insuranceAllowedKey) {
            insuranceAllowed = defaults.bool(forKey: insuranceAllowedKey)
        } else {
            insuranceAllowed = true
        }
        surrenderAllowed = defaults.bool(forKey: surrenderAllowedKey)
        if let _ = defaults.object(forKey: checkHoleCardForDealerBlackJackKey) {
            checkHoleCardForDealerBlackJack = defaults.bool(forKey: checkHoleCardForDealerBlackJackKey)
        } else {
            checkHoleCardForDealerBlackJack = true
        }
        if let _ = defaults.object(forKey: dealerMustHitSoft17Key) {
            dealerMustHitSoft17 = defaults.bool(forKey: dealerMustHitSoft17Key)
        } else {
            dealerMustHitSoft17 = true
        }
        minimumBet = defaults.double(forKey: minimumBetKey)
        if minimumBet == 0 {
            minimumBet = 5.0
        }
        maximumBet = defaults.double(forKey: maximumBetKey)
        if maximumBet == 0 {
            maximumBet = 100.0
        }
        if maximumBet < minimumBet {
            maximumBet = minimumBet
        }
        maxPlayers = defaults.integer(forKey: maxPlayersKey)
        if maxPlayers == 0 {
            maxPlayers = 1
        }
        if let _ = defaults.object(forKey: autoStandOnPlayer21Key) {
            autoStandOnPlayer21 = defaults.bool(forKey: autoStandOnPlayer21Key)
        } else {
            autoStandOnPlayer21 = true
        }
        if let _ = defaults.object(forKey: autoWagerPreviousBetKey) {
            autoWagerPreviousBet = defaults.bool(forKey: autoWagerPreviousBetKey)
        } else {
            autoWagerPreviousBet = true
        }
        if let _ = defaults.object(forKey: enableSoundEffectsKey) {
            enableSoundEffects = defaults.bool(forKey: enableSoundEffectsKey)
        } else {
            enableSoundEffects = true
        }
        super.init()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(numDecks, forKey: numDecksKey)
        defaults.set(redealThreshold, forKey: redealThresholdKey)
        defaults.set(multipleForPlayerBlackjack, forKey: multipleForPlayerBlackjackKey)
        defaults.set(splitsAllowed, forKey: splitsAllowedKey)
        defaults.set(canSplitAces, forKey: canSplitAcesKey)
        defaults.set(onlyOneCardOnSplitAces, forKey: onlyOneCardOnSplitAcesKey)
        defaults.set(canSplitAny10Cards, forKey: canSplitAny10CardsKey)
        defaults.set(maxHandsWithSplits, forKey: maxHandsWithSplitsKey)
        defaults.set(doublingDownAllowed, forKey: doublingDownAllowedKey)
        defaults.set(doublingDownAllowedOn10and11Only, forKey: doublingDownAllowedOn10and11OnlyKey)
        defaults.set(doublingDownAllowedOn9and10and11Only, forKey: doublingDownAllowedOn9and10and11OnlyKey)
        defaults.set(insuranceAllowed, forKey: insuranceAllowedKey)
        defaults.set(surrenderAllowed, forKey: surrenderAllowedKey)
        defaults.set(checkHoleCardForDealerBlackJack, forKey: checkHoleCardForDealerBlackJackKey)
        defaults.set(minimumBet, forKey: minimumBetKey)
        defaults.set(maximumBet, forKey: maximumBetKey)
        defaults.set(maxPlayers, forKey: maxPlayersKey)
        defaults.set(autoStandOnPlayer21, forKey: autoStandOnPlayer21Key)
        defaults.set(autoWagerPreviousBet, forKey: autoWagerPreviousBetKey)
        defaults.set(enableSoundEffects, forKey: enableSoundEffectsKey)
        defaults.synchronize()
    }
}
