//
//  DealerHandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/17/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class DealerHandContainerViewController: HandContainerViewController, DealerObserver {
    
    private var originalHoleCardFrame: CGRect?
    private var holeCardDisplayNeeded = false


    private var upCardView: PlayingCardView?
    private var holeCardView: PlayingCardView?
    
    private var holeCard: BlackjackCard?
    private var dealerScoreText = ""
    
    
    private var gameOverRequired = false
    private var holeCardFlipRequired = false
    private var dealerViewBusy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func currentDealerHandUpdate(hand: BlackjackHand) {
        dealerScoreText = hand.valueDescription
    }
    
    func flipHoleCard() {
        if busyNow() {
            holeCardFlipRequired = true
        } else {
            holeCardFlipRequired = false
            animating = true
            if holeCardView != nil {
                holeCardView!.userInteractionEnabled = true
                holeCardView!.tag = 1
                if let constraint = holecardOffsetConstraint {
                    constraint.constant = CGFloat(holeCardView!.tag) * view.bounds.size.width /  (CGFloat(cardWidthDivider) * CGFloat(numberOfCardsPerWidth))
                }
            }
            animating = false
        }
    }
    
    override func reset() {
        super.reset()
        originalHoleCardFrame = nil
        
        holeCard = nil
        dealerScoreText = ""
        upCardView = nil
        holeCardView = nil
        dealerScoreText = ""
        gameOverRequired = false
        dealerViewBusy = false
        holeCardFlipRequired = false
        holeCardDisplayNeeded = false

    }
    
    override func finishedAnimating() {
        super.finishedAnimating()
        checkForDisplayQueue()
    }
    
    override func finishedDynamicAnimating() {
        super.finishedDynamicAnimating()
        checkForDisplayQueue()
    }
    
    private func checkForDisplayQueue() {
        if !busyNow()  {
            if holeCardDisplayNeeded {
                displayHoleCard()
            } else if holeCardFlipRequired {
                flipHoleCard()
            }
            else if gameOverRequired {
                gameCompleted()
            } else if displayCardQueue.count > 0  {
                let playingCardView = createCard(displayCardQueue.removeAtIndex(0))
                displayCard(playingCardView)
            } else if labelDisplayNeeded {
                displayLabel()
            }
        }
    }

     
    func addCardToDealerHand(card: BlackjackCard) {
            displayCardQueue.append(card)
    }
    
    
    func addUpCardToDealerHand(card: BlackjackCard) {
//        println("added dealer up card \(card)")
        upCardView = createCard(card)
        animating = true
        let cardFrame = upCardView!.frame
        var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
        
        let smallFrame = CGRectMake(15, cardShoeContainer!.bounds.size.height - 40, 60, 40)
        let smallFrameConverted = view.window!.rootViewController!.view!.convertRect(smallFrame, fromView: cardShoeContainer)
        upCardView!.frame = smallFrameConverted
        self.view.window!.rootViewController!.view!.addSubview(upCardView!)
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.upCardView!.frame = CGRectMake(smallFrameConverted.origin.x, smallFrameConverted.origin.y + 50, smallFrameConverted.size.width, smallFrameConverted.size.height)
            }) { _ in
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.upCardView!.frame = cardShoeRect
                    self.pullCardFromShoe(self.upCardView!)
                    }, completion: { _ in
                                self.animating = false
                            }
                    )
        }
    }
    
    func addHoleCardToDealerHand(card: BlackjackCard) {
        //        println("added dealer hole card \(card)")
        holeCard = card
        holeCardDisplayNeeded = true
        
        // first display the upcard then hole card and then flip the upcard
//        displayInitialCards()
    }
    
    func displayHoleCard() {
        holeCardDisplayNeeded = false
        animating = true
        holeCardView = createCard(holeCard!)
        holeCardView!.userInteractionEnabled = false
        originalHoleCardFrame = holeCardView!.frame
        
        let newFrame = CGRectMake(self.view.bounds.width / cardWidthDivider, 0, self.view.bounds.width / cardWidthDivider, self.view.bounds.height)
        holeCardView!.frame = newFrame

        
        let holeCardCenter = holeCardView!.center
        
        let cardFrame = upCardView!.frame
        var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
        
        let smallFrame = CGRectMake(15, cardShoeContainer!.bounds.size.height - 40, 60, 40)
        let smallFrameConverted = view.window!.rootViewController!.view!.convertRect(smallFrame, fromView: cardShoeContainer)
        holeCardView!.frame = smallFrameConverted
        self.requiredCardCenter = holeCardCenter
        self.view.window!.rootViewController!.view!.addSubview(self.holeCardView!)
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut , animations: {
            self.holeCardView!.frame = CGRectMake(smallFrameConverted.origin.x, smallFrameConverted.origin.y + 50, smallFrameConverted.size.width, smallFrameConverted.size.height)
            }, completion: { _ in
                UIView.animateWithDuration( 0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.holeCardView!.frame = cardShoeRect
                    self.pullCardFromShoe(self.holeCardView!)
                    }, completion: { _ in
                        
                        self.requiredCardCenter = nil
                        UIView.transitionWithView(self.upCardView!, duration: 0.3, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                            self.upCardView!.faceUp = true
                            }, completion: { _ in
                                //                                                delay(seconds: 0.2) {
                                self.animating = false
                                //                                                }
                                //                                                println("finished animating initial cards")
                            }
                        )}
                )}
        )
    }
      
    func gameCompleted() {
        if busyNow() {
            gameOverRequired = true
            return
        } else {
            gameOverRequired = false
        }
        animating = true
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut , animations: {
            self.holeCardView!.frame = self.originalHoleCardFrame!
            }, completion: { _ in
                UIView.transitionWithView(self.holeCardView!, duration: 0.2, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                    self.holeCardView!.faceUp = true
                    }, completion: { _ in
//                        self.revealRemainingCards(2)
                        self.labelDisplayNeeded = true
                        self.animating = false
                })
        } )
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
            label!.text = self.dealerScoreText
            switch self.dealerScoreText {
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
                    self.addLabelConstraints()
                    self.view.window!.rootViewController!.view!.userInteractionEnabled = true
                    self.animating = false
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.dealerHandOver, object: nil)
            })
            labelDisplayNeeded = false
        }
    }

}
