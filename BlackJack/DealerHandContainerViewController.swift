//
//  DealerHandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/17/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class DealerHandContainerViewController: UIViewController, DealerObserver {
    private var cardViews: [PlayingCardView] = []
    
    private var originalHoleCardFrame: CGRect?
    
    private var upCardView: PlayingCardView?
    private var holeCardView: PlayingCardView?
    
    private var dealerScoreText = ""
    
    private let cardWidthDivider: CGFloat = 3.0
    private let numberOfCardsPerWidth: CGFloat = 4.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func currentDealerHandUpdate(hand: BlackjackHand) {
        dealerScoreText = hand.valueDescription
    }
    
    func flipHoleCard() {
       
    }
    
    func reset() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        cardViews = []
        upCardView = nil
        holeCardView = nil
        dealerScoreText = ""
    }
    
    func addCardToDealerHand(card: BlackjackCard) {
        println("added dealer card \(card)")
        displayCard(card)
    }
    
    func addUpCardToDealerHand(card: BlackjackCard) {
        displayCard(card)
        upCardView = cardViews[0]
        upCardView!.faceUp = false
        self.view.addSubview(upCardView!)
    }
    
    func addHoleCardToDealerHand(card: BlackjackCard) {
        displayCard(card)
        holeCardView = cardViews[1]
        holeCardView!.faceUp = false
        originalHoleCardFrame = holeCardView!.frame
        self.view.addSubview(holeCardView!)
        
        let newFrame = CGRectMake(self.view.bounds.width / cardWidthDivider, 0, self.view.bounds.width / cardWidthDivider, self.view.bounds.height)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut , animations: {
            //
            self.holeCardView!.frame = newFrame
            }, completion: { _ in
                UIView.transitionWithView(self.upCardView!, duration: 0.15, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                    self.upCardView!.faceUp = true
                    }, completion: nil)
        } )
    }
    
    func displayCard(card: BlackjackCard) {
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height))
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
    }
    
    func gameCompleted() {
        println("game over")
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut , animations: {
            //
            self.holeCardView!.frame = self.originalHoleCardFrame!
            }, completion: { _ in
                UIView.transitionWithView(self.holeCardView!, duration: 0.15, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                    self.holeCardView!.faceUp = true
                    }, completion: { _ in
                        self.revealRemainingCards(2)
                })
        } )
    }

    func revealRemainingCards(index:Int) {
        if index < cardViews.count {
            UIView.animateWithDuration(0.1, delay: 0.0 , options: .CurveEaseOut, animations: {
                self.view.addSubview(self.cardViews[index])
                }, completion: { _ in
                    UIView.transitionWithView(self.cardViews[index], duration: 0.5, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                        self.cardViews[index].faceUp = true
                        }, completion: { _ in
                            let newIndex = index + 1
                            self.revealRemainingCards(newIndex)
                    })
            })
        } else {
            // we are done with displaying the cards, now display the score label
            let label = UILabel(frame: self.view.frame)
            label.textAlignment = NSTextAlignment.Center
            label.text = self.dealerScoreText
            switch self.dealerScoreText {
                case "Busted!":
                label.backgroundColor = UIColor.greenColor()
                case "Jackpot!":
                label.backgroundColor = UIColor.orangeColor()
            default:
                label.backgroundColor = UIColor.yellowColor()
                label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            }
            label.alpha = 0.0
            self.view.addSubview(label)
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                label.sizeToFit()
                label.alpha = 1.0
                label.center = self.view.center
                }, completion: { _ in
                    //
            })
        }
    }
    
}
