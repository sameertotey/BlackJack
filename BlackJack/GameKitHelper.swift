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
        localPlayer.authenticateHandler = {(viewController:UIViewController!, error:NSError!) in
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
}