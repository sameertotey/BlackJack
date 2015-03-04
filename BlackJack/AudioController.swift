//
//  AudioController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/28/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import AVFoundation

class AudioController: NSObject {
    
    enum GameSound: String {
        case Won       = "Won"
        case Lost      = "Lost"
        case Tied      = "Tied"
        case Busted    = "Busted"
        case CardDraw  = "CardDraw"
        case Blackjack = "Blackjack"
        case Beep      = "Beep"
        case Coin      = "Coin"
        
        var soundFile: SystemSoundID {
            switch self {
            case .Won:
                return GameSounds.won
            case .Lost:
                return GameSounds.lost
            case .Tied:
                return GameSounds.tied
            case .Busted:
                return GameSounds.busted
            case .CardDraw:
                return GameSounds.cardDraw
            case .Blackjack:
                return GameSounds.blackjack
            case .Beep:
                return GameSounds.beep
            case .Coin:
                return GameSounds.coin
            }
        }
        
        func setSoundFileID(#soundID: SystemSoundID) {
            switch self {
            case .Won:
                GameSounds.won = soundID
            case .Lost:
                GameSounds.lost = soundID
            case .Tied:
                GameSounds.tied = soundID
            case .Busted:
                GameSounds.busted = soundID
            case .CardDraw:
                GameSounds.cardDraw = soundID
            case .Blackjack:
                GameSounds.blackjack = soundID
            case .Beep:
                GameSounds.beep = soundID
            case .Coin:
                GameSounds.coin = soundID
            }
            
        }
    }
    
    struct GameSounds {
        static var soundEffectsEnabled = true
        static var busted: SystemSoundID = 0
        static var cardDraw: SystemSoundID = 0
        static var won: SystemSoundID = 0
        static var lost: SystemSoundID = 0
        static var tied: SystemSoundID = 0
        static var blackjack: SystemSoundID = 0
        static var beep: SystemSoundID = 0
        static var coin: SystemSoundID = 0
    }
    
    override init() {
        let path = NSBundle.mainBundle().pathForResource("Sounds", ofType: "plist")
        let soundsDictionary = NSDictionary(contentsOfFile: path!)
        var soundsArrayRaw: AnyObject? = soundsDictionary?.objectForKey("Sounds")
        
        if let soundsArray: AnyObject = soundsArrayRaw {
            for soundItemDictionary in soundsArray as NSArray {
                let dict = soundItemDictionary as Dictionary<String, String>
                if let purpose = dict["Purpose"] {
                    var myGameSound = GameSound(rawValue: purpose)
                    if let gameSound = myGameSound {
                        var gameSoundID = gameSound.soundFile
                        let urlName = dict["Name"]
                        let urlExtension = dict["Extension"]
                        let soundURL = NSBundle.mainBundle().URLForResource(urlName!, withExtension: urlExtension)
                        AudioServicesCreateSystemSoundID(soundURL, &gameSoundID)
                        gameSound.setSoundFileID(soundID: gameSoundID)
                    }
                }
            }
        }
        
        
    }
    
    class func play(gameSound: GameSound) {
        // Play
        if GameSounds.soundEffectsEnabled {
            AudioServicesPlaySystemSound(gameSound.soundFile)
        }
    }
   
}
