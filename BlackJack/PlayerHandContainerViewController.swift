//
//  PlayerHandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class PlayerHandContainerViewController: HandContainerViewController {
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
            let playingCardView = createCard(card: card)
            displayCard(playingCardView: playingCardView)
        } else {
                displayCardQueue.append(card)
        }
    }
    
    private func checkForDisplayQueue() {
        if !busyNow()  {
            if displayCardQueue.count > 0  {

                let playingCardView = createCard(card: displayCardQueue.remove(at: 0))
                displayCard(playingCardView: playingCardView)
            } else if labelDisplayNeeded {
                displayLabel()
            }  else if resultDisplayNeeded{
                if savedResultState != nil {
                    displayResult(resultState: savedResultState!)
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
            label!.translatesAutoresizingMaskIntoConstraints = false
            label!.textAlignment = NSTextAlignment.center
            label!.text = self.playerScoreText
            switch self.playerScoreText {
            case "Busted!":
                label!.backgroundColor = UIColor.green
            case "Blackjack!":
                label!.backgroundColor = UIColor.orange
            default:
                label!.backgroundColor = UIColor.yellow
                label!.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
            }
            label!.alpha = 0.0
            label!.sizeToFit()
            label!.frame = CGRect(x: 0, y: 0, width: label!.bounds.size.width, height: label!.bounds.size.height)
            let myX = CGRect(origin: self.cardViews[self.cardViews.count - 1].frame.origin, size: self.cardViews[self.cardViews.count - 1].frame.size).maxX
            self.view.addSubview(label!)
            UIView.animate( withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.label!.alpha = 1.0
                self.label!.frame = CGRect(x: myX, y: 0, width: self.label!.bounds.size.width, height: self.label!.bounds.size.height)
                }, completion: { _ in
                    self.addLabelConstraints()
                    self.view.window!.rootViewController!.view!.isUserInteractionEnabled = true
                    self.animating = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationMessages.setPlayerReady), object: nil)

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
            let card = cards.remove(at: 0)
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
            resultLabel!.backgroundColor = UIColor.green
        case .Lost:
            resultLabel!.text = "😢"
            resultLabel!.backgroundColor = UIColor.orange
        case .Tied:
            resultLabel!.text = "😑"
            resultLabel!.backgroundColor = UIColor.gray
        case .NaturalBlackjack:
            resultLabel!.text = "💰"
            resultLabel!.backgroundColor = UIColor.yellow
        case .Surrendered:
            resultLabel!.text = "⚐"
            resultLabel!.backgroundColor = UIColor.red
        case .Stood:
            print("Stood")
        case .Active:
            print("Active")
        default:
            print("unknown result")
        }
        resultLabel!.textAlignment = NSTextAlignment.center
        resultLabel!.font = UIFont.systemFont(ofSize: 30)
        
        resultLabel!.alpha = 0.0
        resultLabel!.sizeToFit()
        
        var myX = view.bounds.width / 2
        if cardViews.count > 0 {
            myX = CGRect(origin: cardViews[cardViews.count - 1].frame.origin, size: cardViews[cardViews.count - 1].frame.size).maxX / 2
        }
        let myY = view.bounds.height / 2
        self.view.addSubview(resultLabel!)
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
                self.resultLabel!.alpha = 1.0
                self.resultLabel!.center = CGPoint(x: myX, y: myY)
            }, completion: { _ in
                self.animating = false
                self.view.window!.rootViewController!.view!.isUserInteractionEnabled = true
        })
    }
    
 }
