//
//  Game.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class Game: NSObject {
    struct Hand {
        let player: Player
        let bet = 0.0
        var doubled = false
        var cards = [BlackjackCard]()
        }
    
    var player =  [Player]()
    
    var hands = [Hand]()
    
    var currentPlayer: Player?
    
    var cardShoe = [BlackjackCard]()
    
    
}
