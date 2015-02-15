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
    let maxSplitsAllowedKey = "MaxSplitsAllowedKey"
    let doublingDownAllowedKey = "DoublingDownAllowedKey"
    let insuranceAllowedKey = "InsuranceAllowedKey"
    let surrenderAllowedKey = "SurrenderAllowedKey"
    let minimumBetKey = "MinimumBetKey"
    let maximumBetKey = "MaximumBetKey"
    let maxPlayersKey = "MaxPlayersKey"
    
    var numDecks = 6
    var redealThreshold = 25
    var multipleForPlayerBlackjack = 1.5
    var splitsAllowed = true
    var maxSplitsAllowed = 3
    var doublingDownAllowed = true
    var insuranceAllowed = true
    var surrenderAllowed = false
    var minimumBet = 5.0
    var maximumBet = 100.0
    var maxPlayers = 1
    
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
        splitsAllowed = defaults.boolForKey(splitsAllowedKey)
        maxSplitsAllowed = defaults.integerForKey(maxSplitsAllowedKey)
        doublingDownAllowed = defaults.boolForKey(doublingDownAllowedKey)
        insuranceAllowed = defaults.boolForKey(insuranceAllowedKey)
        surrenderAllowed = defaults.boolForKey(surrenderAllowedKey)
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
        
        super.init()
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(numDecks, forKey: numDecksKey)
        defaults.setInteger(redealThreshold, forKey: redealThresholdKey)
        defaults.setDouble(multipleForPlayerBlackjack, forKey: multipleForPlayerBlackjackKey)
        defaults.setBool(splitsAllowed, forKey: splitsAllowedKey)
        defaults.setInteger(maxSplitsAllowed, forKey: maxSplitsAllowedKey)
        defaults.setBool(doublingDownAllowed, forKey: doublingDownAllowedKey)
        defaults.setBool(insuranceAllowed, forKey: insuranceAllowedKey)
        defaults.setBool(surrenderAllowed, forKey: surrenderAllowedKey)
        defaults.setDouble(minimumBet, forKey: minimumBetKey)
        defaults.setDouble(maximumBet, forKey: maximumBetKey)
        defaults.setInteger(maxPlayers, forKey: maxPlayersKey)
        defaults.synchronize()
    }
}
