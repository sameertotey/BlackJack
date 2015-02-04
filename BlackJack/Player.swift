//
//  Player.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class Player: NSObject {
    var name: String?
    var bankRoll = 0.0
    
    enum Action: Int {
        case Hit = 1, Stand, Split, DoubleDown, Surrender, BuyInsurance
    }
    
    func bet(amount: Double) -> Bool {
        if (bankRoll - amount) >= 0.0 {
            bankRoll -= amount
            return true
        }
        return false
    }
    
    func hit() {
        
    }
    
    func stand() {
        
    }
    
    func split() {
        
    }
    
    func doubleDown() {
        
    }
    
    func buyInsurance() {
        
    }
    
    func surrenderHand() {
        
    }
}
