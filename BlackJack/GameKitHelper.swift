//
//  GameKitHelper.swift
//  Blackjack
//
//  Created by Sameer Totey on 1/17/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import GameKit

let presentGameCenterAuthenticationVeiwController = "com.sameertotey.presentGameCenterAuthenticatonViewController"

class GameKitHelper : NSObject {
    var enableGameCenter:Bool = true
    
    var authenticationVC:UIViewController?
    var currentPlayerID: String?
    var lastError: NSError?
    
    override init() {
        enableGameCenter = true
        authenticationVC = nil
        currentPlayerID = nil
        lastError = NSError(domain: "Blackjack", code: 0, userInfo: nil)
    }
    
    func authenticateLocalPlayer() {
//        println("Authenticate Local Player called")
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) in
            self.lastError = error
            if viewController != nil {
                self.authenticationVC = viewController
                let notification = NSNotification(name: presentGameCenterAuthenticationVeiwController, object: viewController)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            } else if localPlayer.authenticated {
                if self.currentPlayerID != localPlayer.playerID {
                    self.currentPlayerID = localPlayer.playerID
                }
                self.enableGameCenter = true
            } else {
                self.enableGameCenter = false
            }
        }
    }
    
    
    func reportScore(score:Int64, leaderBoardID:String) {
        let scoreReporter = GKScore(leaderboardIdentifier: leaderBoardID)
        scoreReporter.value = score
        //        println("Reporting Score \(score)")
        scoreReporter.context = 0
        GKScore.reportScores([scoreReporter], withCompletionHandler: { error in
            self.lastError = error
        })
    }
    
    func gameDidEnd(#score: Int?) {
        var level:Int?
        switch score {
        case let x where x <= 2000:
            level = 1
        case let x where x <= 5000:
            level = 2
        default:
            level = 3
        }
        //        println("Scored \(score) at level \(level)")
        if let reportingScore = score {
            var myScore: Int64
            myScore = Int64(reportingScore)
            reportScore(myScore, leaderBoardID: gameCenterLeaderBoardID)
            if let reportingLevel = level {
                var myLevel = reportingLevel - 1
                var myPercent:Double
                myPercent = Double(myScore) % 200.00
                var achievements = [String:Double]()
                switch myLevel {
                case 0:
                    achievements["BlackjackLevel1"] = Double(myScore) / 2000
                    achievements["BlackjackLevel2"] = 0.00
                case 1:
                    achievements["BlackjackLevel1"] = 100.0
                    achievements["BlackjackLevel2"] = Double(myScore) / 5000
                case 2:
                    achievements["BlackjackLevel1"] = 100.0
                    achievements["BlackjackLevel2"] = 100.00
                default:
                    println("Somebody have moved to higher levels!!!!")
                }
                reportAllAchievements(achievements)
            }
        }
    }
    
    func reportAllAchievements(achievements:Dictionary<String, Double>) {
        var myAchievements = [GKAchievement]()
        for (identifier, percent) in achievements {
            let achievement = GKAchievement(identifier: identifier)
            achievement.percentComplete = percent
            //            println("Reporting achievement \(identifier) for \(percent)")
            myAchievements.append(achievement)
        }
        GKAchievement.reportAchievements(myAchievements, withCompletionHandler: { (error) -> Void in
            //            println("Completed Sending Achievements with Error: \(error)")
        })
        
    }
    

}