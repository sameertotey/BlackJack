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
    
    override init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        numDecks = defaults.integerForKey(numDecksKey)
        if  numDecks == 0 {
            numDecks = 6
        }
        redealThreshold = defaults.integerForKey(redealThresholdKey)
        if redealThreshold == 0 {
            redealThreshold = 25
        }
        multipleForPlayerBlackjack = defaults.doubleForKey(multipleForPlayerBlackjackKey)
        if multipleForPlayerBlackjack == 0 {
            multipleForPlayerBlackjack = 1.5
        }
        if let testValue: AnyObject = defaults.objectForKey(splitsAllowedKey) {
            splitsAllowed = defaults.boolForKey(splitsAllowedKey)
        } else {
            splitsAllowed = true
        }
        if let testValue: AnyObject = defaults.objectForKey(canSplitAcesKey) {
            canSplitAces = defaults.boolForKey(canSplitAcesKey)
        } else {
            canSplitAces = true
        }
        if let testValue: AnyObject = defaults.objectForKey(onlyOneCardOnSplitAcesKey) {
            onlyOneCardOnSplitAces = defaults.boolForKey(onlyOneCardOnSplitAcesKey)
        } else {
            onlyOneCardOnSplitAces = true
        }
        if let testValue: AnyObject = defaults.objectForKey(canSplitAny10CardsKey) {
            canSplitAny10Cards = defaults.boolForKey(canSplitAny10CardsKey)
        } else {
            canSplitAny10Cards = false
        }
        maxHandsWithSplits = defaults.integerForKey(maxHandsWithSplitsKey)
        if let testValue: AnyObject = defaults.objectForKey(doublingDownAllowedKey) {
            doublingDownAllowed = defaults.boolForKey(doublingDownAllowedKey)
        } else {
            doublingDownAllowed = true
        }
        if let testValue: AnyObject = defaults.objectForKey(doublingDownAllowedOn10and11OnlyKey) {
            doublingDownAllowedOn10and11Only = defaults.boolForKey(doublingDownAllowedOn10and11OnlyKey)
        } else {
            doublingDownAllowedOn10and11Only = false
        }
        if let testValue: AnyObject = defaults.objectForKey(doublingDownAllowedOn9and10and11OnlyKey) {
            doublingDownAllowedOn9and10and11Only = defaults.boolForKey(doublingDownAllowedOn9and10and11OnlyKey)
        } else {
            doublingDownAllowedOn9and10and11Only = false
        }
        if let testValue: AnyObject = defaults.objectForKey(insuranceAllowedKey) {
            insuranceAllowed = defaults.boolForKey(insuranceAllowedKey)
        } else {
            insuranceAllowed = true
        }
        surrenderAllowed = defaults.boolForKey(surrenderAllowedKey)
        if let testValue: AnyObject = defaults.objectForKey(checkHoleCardForDealerBlackJackKey) {
            checkHoleCardForDealerBlackJack = defaults.boolForKey(checkHoleCardForDealerBlackJackKey)
        } else {
            checkHoleCardForDealerBlackJack = true
        }
        if let testValue: AnyObject = defaults.objectForKey(dealerMustHitSoft17Key) {
            dealerMustHitSoft17 = defaults.boolForKey(dealerMustHitSoft17Key)
        } else {
            dealerMustHitSoft17 = true
        }
        minimumBet = defaults.doubleForKey(minimumBetKey)
        if minimumBet == 0 {
            minimumBet = 5.0
        }
        maximumBet = defaults.doubleForKey(maximumBetKey)
        if maximumBet == 0 {
            maximumBet = 100.0
        }
        if maximumBet < minimumBet {
            maximumBet = minimumBet
        }
        maxPlayers = defaults.integerForKey(maxPlayersKey)
        if maxPlayers == 0 {
            maxPlayers = 1
        }
        if let testValue: AnyObject = defaults.objectForKey(autoStandOnPlayer21Key) {
            autoStandOnPlayer21 = defaults.boolForKey(autoStandOnPlayer21Key)
        } else {
            autoStandOnPlayer21 = true
        }
        if let testValue: AnyObject = defaults.objectForKey(autoWagerPreviousBetKey) {
            autoWagerPreviousBet = defaults.boolForKey(autoWagerPreviousBetKey)
        } else {
            autoWagerPreviousBet = true
        }
        super.init()
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(numDecks, forKey: numDecksKey)
        defaults.setInteger(redealThreshold, forKey: redealThresholdKey)
        defaults.setDouble(multipleForPlayerBlackjack, forKey: multipleForPlayerBlackjackKey)
        defaults.setBool(splitsAllowed, forKey: splitsAllowedKey)
        defaults.setBool(canSplitAces, forKey: canSplitAcesKey)
        defaults.setBool(onlyOneCardOnSplitAces, forKey: onlyOneCardOnSplitAcesKey)
        defaults.setBool(canSplitAny10Cards, forKey: canSplitAny10CardsKey)
        defaults.setInteger(maxHandsWithSplits, forKey: maxHandsWithSplitsKey)
        defaults.setBool(doublingDownAllowed, forKey: doublingDownAllowedKey)
        defaults.setBool(doublingDownAllowedOn10and11Only, forKey: doublingDownAllowedOn10and11OnlyKey)
        defaults.setBool(doublingDownAllowedOn9and10and11Only, forKey: doublingDownAllowedOn9and10and11OnlyKey)
        defaults.setBool(insuranceAllowed, forKey: insuranceAllowedKey)
        defaults.setBool(surrenderAllowed, forKey: surrenderAllowedKey)
        defaults.setBool(checkHoleCardForDealerBlackJack, forKey: checkHoleCardForDealerBlackJackKey)
        defaults.setDouble(minimumBet, forKey: minimumBetKey)
        defaults.setDouble(maximumBet, forKey: maximumBetKey)
        defaults.setInteger(maxPlayers, forKey: maxPlayersKey)
        defaults.setBool(autoStandOnPlayer21, forKey: autoStandOnPlayer21Key)
        defaults.setBool(autoWagerPreviousBet, forKey: autoWagerPreviousBetKey)
        defaults.synchronize()
    }
}
