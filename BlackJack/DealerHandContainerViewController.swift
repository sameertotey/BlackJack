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
    private var displayCardQueue: [BlackjackCard] = []
    private var cards: [BlackjackCard] = []
    private var labelDisplayNeeded = false
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
        displayCardQueue.removeAll()
        cards.removeAll(keepCapacity: false)
        cardViews.removeAll(keepCapacity: false)
        upCardView = nil
        holeCardView = nil
        dealerScoreText = ""
        gameOverRequired = false
        dealerViewBusy = false
        holeCardFlipRequired = false
        labelDisplayNeeded = false
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

    private func displayCard(playingCardView: PlayingCardView) {
        animating = true
        if cardShoeContainer != nil {
            let cardFrame = playingCardView.frame
            //            requiredCardCenter = playingCardView.center
            var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
            
            let smallFrame = CGRectMake(15, cardShoeContainer!.bounds.size.height - 40, 60, 40)
            let smallFrameConverted = view.window!.rootViewController!.view!.convertRect(smallFrame, fromView: cardShoeContainer)
            playingCardView.frame = smallFrameConverted
            self.view.window!.rootViewController!.view!.addSubview(playingCardView)
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                playingCardView.frame = CGRectMake(smallFrameConverted.origin.x, smallFrameConverted.origin.y + 50, smallFrameConverted.size.width, smallFrameConverted.size.height)
                }) { _ in
                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                        playingCardView.frame = cardShoeRect
                        self.pullCardFromShoe(playingCardView)
                        }, completion: { _ in
                            UIView.transitionWithView(playingCardView, duration: 0.2, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                                playingCardView.faceUp = true
                                }, completion: { _ in
                                    self.animating = false
                                    self.labelDisplayNeeded = true
                                }
                            )}
                    )}
        } else {
            view.addSubview(playingCardView)
            addConstraints(playingCardView, holeCard: false)
            playingCardView.alpha = 0
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                playingCardView.alpha = 1.0
                }, completion: {_ in
                    UIView.transitionWithView(playingCardView, duration: 0.3, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                        playingCardView.faceUp = true
                        
                        }) { _ in
                            //
                            self.animating = false
                            self.labelDisplayNeeded = true
                    }
            })
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
    
    private func createCard(card: BlackjackCard) -> PlayingCardView{
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height))
        playingCardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        playingCardView.tag = cardViews.count
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
        cards.append(playingCardView.card)
        return playingCardView

    }
    
    func gameCompleted() {
        println("game over initial")
        if busyNow() {
            gameOverRequired = true
            println("Still animating .. will wait for animation to complete")
            return
        } else {
            gameOverRequired = false
        }
        animating = true
        println("game over final")
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut , animations: {
            println("game over final 1")

            self.holeCardView!.frame = self.originalHoleCardFrame!
            }, completion: { _ in
                println("game over final 2")

                UIView.transitionWithView(self.holeCardView!, duration: 0.2, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                    self.holeCardView!.faceUp = true
                    }, completion: { _ in
//                        self.revealRemainingCards(2)
                        println("game over final 3")

                        self.labelDisplayNeeded = true
                        self.animating = false
                })
        } )
    }

    
    private func displayLabel() {
        println("Display label code ..........")
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
                    self.animating = false
                    self.addLabelConstraints()
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.dealerHandOver, object: nil)

            })
            labelDisplayNeeded = false
        }
    }

}
