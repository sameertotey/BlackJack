//
//  PlayerHandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class PlayerHandContainerViewController: HandContainerViewController, UIDynamicAnimatorDelegate {
    private var playerScoreText = ""
    private var resultLabel: UILabel?
    var playerHandIndex: Int? {
        didSet {
            if oldValue != playerHandIndex {
//                println("The player hand index is now changing to...\(playerHandIndex)")
            }
        }
    }
    
    private var labelX: CGFloat?
    
    private var resultDisplayNeeded = false
    private var savedResultState: BlackjackHand.HandState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func reset() {
        super.reset()
        resultDisplayNeeded = false
        playerScoreText = ""
        resultLabel = nil
        playerHandIndex = nil
        savedResultState = nil
     }
    
    override func finishedAnimating() {
        super.finishedAnimating()
        checkForDisplayQueue()
        
    }
    
    override func finishedDynamicAnimating() {
        super.finishedDynamicAnimating()
        checkForDisplayQueue()
    }

    func addCardToPlayerHand(card: BlackjackCard) {
         if !busyNow() {
            let playingCardView = createCard(card)
            displayCard(playingCardView)
        } else {
                displayCardQueue.append(card)
        }
    }
    
    private func checkForDisplayQueue() {
        if !busyNow()  {
            if displayCardQueue.count > 0  {

                let playingCardView = createCard(displayCardQueue.removeAtIndex(0))
                displayCard(playingCardView)
            } else if labelDisplayNeeded {
                displayLabel()
            }  else if resultDisplayNeeded{
                if savedResultState != nil {
                    displayResult(savedResultState!)
                }
            }
        }
    }
    
    private func displayLabel() {
        if cardViews.count > 1 {
            animating = true
            if label == nil {
                label = UILabel(frame: self.view.frame)
            } else {
                label!.removeFromSuperview()
            }
            label!.setTranslatesAutoresizingMaskIntoConstraints(false)
            label!.textAlignment = NSTextAlignment.Center
            label!.text = self.playerScoreText
            switch self.playerScoreText {
            case "Busted!":
                label!.backgroundColor = UIColor.greenColor()
            case "Blackjack!":
                label!.backgroundColor = UIColor.orangeColor()
            default:
                label!.backgroundColor = UIColor.yellowColor()
                label!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            }
            label!.alpha = 0.0
            label!.sizeToFit()
            label!.frame = CGRectMake(0, 0, label!.bounds.size.width, label!.bounds.size.height)
            let myX = CGRectGetMaxX(self.cardViews[self.cardViews.count - 1].frame)
            self.view.addSubview(label!)
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                self.label!.alpha = 1.0
                self.label!.frame = CGRectMake(myX, 0, self.label!.bounds.size.width, self.label!.bounds.size.height)
                }, completion: { _ in
                    self.animating = false
                    self.addLabelConstraints()
                    println("finished the player label")
                    
                    self.view.window!.rootViewController!.view!.userInteractionEnabled = true
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.playerLabelDisplayed, object: nil)


            })
            labelDisplayNeeded = false
        }
    }
    
    func setPlayerScoreText(text: String) {
        playerScoreText = text
    }
    
    func getPlayerScoreText() -> String {
        return playerScoreText
    }

    func removeLastCard(withView: Bool) -> BlackjackCard? {
        if cards.count > 0 {
            let card = cards.removeLast()
            if withView {
                removeLastCardView()
            }
            return card
        } else {
            return nil
        }
    }
    
    private func removeLastCardView() {
        let cardView = cardViews.removeLast()
        cardView.removeFromSuperview()
        label?.removeFromSuperview()
        resultLabel?.removeFromSuperview()
        removeLastConstraint()
    }
    
    private func removeLastConstraint() {
        heightConstraints.removeLast()
        widthConstraints.removeLast()
        leftOffsetConstraints.removeLast()
//        updateLabelConstraint(CGRectGetMaxX(cardViews[cardViews.count - 1].frame))
    }
    
    func removeFirstCard() -> BlackjackCard? {
        if cards.count > 0 {
            let card = cards.removeAtIndex(0)
            return card
        } else {
            return nil
        }
    }
    
 
    func displayResult(resultState: BlackjackHand.HandState) {
        if busyNow() {
            resultDisplayNeeded = true
            savedResultState = resultState
            return
        }
        animating = true
        savedResultState = nil
        resultLabel = UILabel()
        switch resultState {
        case .Won:
            resultLabel!.text = "😃"
            resultLabel!.backgroundColor = UIColor.greenColor()
        case .Lost:
            resultLabel!.text = "😢"
            resultLabel!.backgroundColor = UIColor.orangeColor()
        case .Tied:
            resultLabel!.text = "😑"
            resultLabel!.backgroundColor = UIColor.grayColor()
        case .NaturalBlackjack:
            resultLabel!.text = "💰"
            resultLabel!.backgroundColor = UIColor.yellowColor()
        case .Surrendered:
            resultLabel!.text = "⚐"
            resultLabel!.backgroundColor = UIColor.redColor()
        case .Stood:
            println("Stood")
        case .Active:
            println("Active")
        default:
            println("unknown result")
        }
        resultLabel!.textAlignment = NSTextAlignment.Center
        resultLabel!.font = UIFont.systemFontOfSize(30)
        
        resultLabel!.alpha = 0.0
        resultLabel!.sizeToFit()
        
        var myX = view.bounds.width / 2
        if cardViews.count > 0 {
            myX = CGRectGetMaxX(cardViews[cardViews.count - 1].frame) / 2
        }
        let myY = view.bounds.height / 2
        self.view.addSubview(resultLabel!)
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                self.resultLabel!.alpha = 1.0
                self.resultLabel!.center = CGPointMake(myX, myY)
            }, completion: { _ in
                self.animating = false
                self.view.window!.rootViewController!.view!.userInteractionEnabled = true
        })
    }
    
 }
