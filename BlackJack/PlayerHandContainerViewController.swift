//
//  PlayerHandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class PlayerHandContainerViewController: UIViewController {
    private var cardViews: [PlayingCardView] = []
    private var playerScoreText = ""
    private var label: UILabel?
    private var resultLabel: UILabel?
    var playerHandIndex: Int?
    
    var cardWidthDivider: CGFloat = 3.0
    var numberOfCardsPerWidth: CGFloat = 4.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func reset() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        cardViews = []
        playerScoreText = ""
        label = nil
        resultLabel = nil
        playerHandIndex = nil
    }
    
    func addCardToPlayerHand(card: BlackjackCard) {
        println("added player card \(card)")
        displayCard(card)
    }
    
    func displayCard(card: BlackjackCard) {
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRectMake(0, 0, cardWidth, self.view.bounds.height))
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
        view.addSubview(playingCardView)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            playingCardView.frame = CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height)
            }, completion: {_ in
        UIView.transitionWithView(playingCardView, duration: 0.3, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
            playingCardView.faceUp = true

        }) { _ in
            //
            self.displayLabel()
            }
        })
    }
    
    func displayLabel() {
        if let label = self.label {
            label.removeFromSuperview()
            
            label.textAlignment = NSTextAlignment.Center
            label.text = self.playerScoreText
            switch self.playerScoreText {
            case "Busted!":
                label.backgroundColor = UIColor.greenColor()
            case "Blackjack!":
                label.backgroundColor = UIColor.orangeColor()
            default:
                label.backgroundColor = UIColor.yellowColor()
                label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            }
            label.alpha = 0.0
            label.sizeToFit()
            label.frame = CGRectMake(0, 0, label.bounds.size.width, label.bounds.size.height)
            let myX = CGRectGetMaxX(self.cardViews[self.cardViews.count - 1].frame)
            self.view.addSubview(label)
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                label.alpha = 1.0
                println("displaying label \(label.text)")
                label.frame = CGRectMake(myX, 0, label.bounds.size.width, label.bounds.size.height)
                }, completion: { _ in
                    //
            })
            
        } else {
            self.label = UILabel(frame: self.view.frame)
        }
    }
    
    func gameCompleted() {
     }
    
    func setPlayerScoreText(text: String) {
        playerScoreText = text
    }
    
    func getPlayerScoreText() -> String {
        return playerScoreText
    }

    func removeLastCard() -> PlayingCardView? {
        if cardViews.count > 0 {
            let cardView = cardViews.removeLast()
            cardView.removeFromSuperview()
            return cardView
        } else {
            return nil
        }
    }
    
    func removeFirstCard() -> PlayingCardView? {
        if cardViews.count > 0 {
            let cardView = cardViews.removeAtIndex(0)
            cardView.removeFromSuperview()
            return cardView
        } else {
            return nil
        }
    }

    func displayResult(resultState: BlackjackHand.HandState) {
        resultLabel = UILabel()
        switch resultState {
        case .Won:
            println("Won")
            resultLabel!.text = "😃"
            resultLabel!.backgroundColor = UIColor.greenColor()
        case .Lost:
            println("Lost")
            resultLabel!.text = "😢"
            resultLabel!.backgroundColor = UIColor.orangeColor()
        case .Tied:
            println("Tied")
            resultLabel!.text = "😑"
            resultLabel!.backgroundColor = UIColor.grayColor()
        case .NaturalBlackjack:
            println("Blackjack")
        case .Surrendered:
            println("Surrendered")
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
 
        let myX = CGRectGetMaxX(self.cardViews[self.cardViews.count - 1].frame) / 2
        let myY = view.bounds.height / 2
        self.view.addSubview(resultLabel!)
        UIView.animateWithDuration(0.2, delay: 0.8, options: .CurveEaseOut, animations: {
            self.resultLabel!.alpha = 1.0
            self.resultLabel!.center = CGPointMake(myX, myY)
            }, completion: { _ in
                //
        })

    }
}
