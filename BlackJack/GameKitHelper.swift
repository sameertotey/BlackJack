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
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = {(viewController, error) in
            self.lastError = error! as NSError
            if viewController != nil {
                self.authenticationVC = viewController
                let notification = NSNotification(name: NSNotification.Name(rawValue: presentGameCenterAuthenticationVeiwController), object: viewController)
                NotificationCenter.default.post(notification as Notification)
            } else if localPlayer.isAuthenticated {
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
        GKScore.report([scoreReporter], withCompletionHandler: { error in
            self.lastError = error
            } as? (Error?) -> Void)
    }
    
    func gameDidEnd(_ score: Int?) {
        var level:Int?
        if let myScore = score {
            switch myScore {
            case let x where x <= 2000:
                level = 1
            case let x where x <= 5000:
                level = 2
            default:
                level = 3
            }
        }
       
        //        println("Scored \(score) at level \(level)")
        if let reportingScore = score {
            var myScore: Int64
            myScore = Int64(reportingScore)
            reportScore(score: myScore, leaderBoardID: gameCenterLeaderBoardID)
            if let reportingLevel = level {
                let myLevel = reportingLevel - 1
                var myPercent:Double
                myPercent = Double(myScore) / 100.00  // need to look into this!
                var achievements = [String:Double]()
                switch myLevel {
                case 0:
                    achievements["BlackjackLevel1"] = Double(myScore) / 20
                    achievements["BlackjackLevel2"] = 0.00
                case 1:
                    achievements["BlackjackLevel1"] = 100.0
                    achievements["BlackjackLevel2"] = Double(myScore) / 50
                case 2:
                    achievements["BlackjackLevel1"] = 100.0
                    achievements["BlackjackLevel2"] = 100.0
                default:
                    print("Somebody have moved to higher levels!!!!")
                }
                reportAllAchievements(achievements: achievements)
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
        GKAchievement.report(myAchievements, withCompletionHandler: { (error) -> Void in
            //            println("Completed Sending Achievements with Error: \(error)")
        })
        
    }
    

}
