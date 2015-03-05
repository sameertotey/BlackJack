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
    private var labelX: CGFloat?

    private var upCardView: PlayingCardView?
    private var holeCardView: PlayingCardView?
    
    
    private var dealerScoreText = ""
    
    
    private var gameOverRequired = false
    private var dealerViewBusy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func currentDealerHandUpdate(hand: BlackjackHand) {
        dealerScoreText = hand.valueDescription
    }
    
    func flipHoleCard() {
        holeCardView!.userInteractionEnabled = true
        holeCardView!.tag = 1
        if let constraint = holecardOffsetConstraint {
             constraint.constant = CGFloat(holeCardView!.tag) * view.bounds.size.width /  (CGFloat(cardWidthDivider) * CGFloat(numberOfCardsPerWidth))
        }
       
    }
    
    override func reset() {
        super.reset()
        upCardView = nil
        holeCardView = nil
        dealerScoreText = ""
        gameOverRequired = false
        dealerViewBusy = false
    }
    
    override func finishedAnimating() {
        super.finishedAnimating()
        checkForGameOver()

    }
    
    override func finishedDynamicAnimating() {
        super.finishedDynamicAnimating()
        checkForGameOver()
    }
    
    func checkForGameOver() {
        if gameOverRequired && !isAnimatorOn {
            gameCompleted()
        }
    }

    func addCardToDealerHand(card: BlackjackCard) {
//        println("added dealer card \(card)")
        createCard(card)
    }
    
    
    func addUpCardToDealerHand(card: BlackjackCard) {
//        println("added dealer up card \(card)")
        createCard(card)
        upCardView = cardViews[0]
        upCardView!.faceUp = false
    }
    
    func addHoleCardToDealerHand(card: BlackjackCard) {
        //        println("added dealer hole card \(card)")
        createCard(card)
        holeCardView = cardViews[1]
        holeCardView!.faceUp = false
        holeCardView!.userInteractionEnabled = false
        originalHoleCardFrame = holeCardView!.frame
        
        let newFrame = CGRectMake(self.view.bounds.width / cardWidthDivider, 0, self.view.bounds.width / cardWidthDivider, self.view.bounds.height)
        holeCardView!.frame = newFrame
        
        // first display the upcard then hole card and then flip the upcard
        displayInitialCards()
    }
    
    private func createCard(card: BlackjackCard) {
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height))
        playingCardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        playingCardView.tag = cardViews.count
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
    }

    private func displayInitialCards() {
        animating = true
        
        let cardFrame = upCardView!.frame
        var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
        
        let smallFrame = CGRectMake(15, cardShoeContainer!.bounds.size.height - 40, 60, 40)
        let smallFrameConverted = view.window!.rootViewController!.view!.convertRect(smallFrame, fromView: cardShoeContainer)
        upCardView!.frame = smallFrameConverted
        let holeCardCenter = holeCardView!.center
        holeCardView!.frame = smallFrameConverted
        view.window!.rootViewController!.view!.addSubview(upCardView!)

        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.upCardView!.frame = CGRectMake(smallFrameConverted.origin.x, smallFrameConverted.origin.y + 50, smallFrameConverted.size.width, smallFrameConverted.size.height)
            }) { _ in
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.upCardView!.frame = cardShoeRect
                    self.pullCardFromShoe(self.upCardView!)
                    }, completion: { _ in
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
                        )}
                )}
    }
    
    func gameCompleted() {
//        println("game over initial")
        if animating {
            gameOverRequired = true
//            println("Still animating .. will wait for animation to complete")
            return
        } else {
            gameOverRequired = false
        }
        animating = true
//        println("game over final")
        self.animator?.removeAllBehaviors()
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut , animations: {
            self.holeCardView!.frame = self.originalHoleCardFrame!
            }, completion: { _ in
                UIView.transitionWithView(self.holeCardView!, duration: 0.2, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                    self.labelX = CGRectGetMaxX(self.cardViews[self.cardViews.count - 1].frame)
                    self.holeCardView!.faceUp = true
                    }, completion: { _ in
                        self.revealRemainingCards(2)
                })
        } )
    }

    private func revealRemainingCards(index:Int) {
        if index < cardViews.count {
            let cardFrame = cardViews[index].frame
            var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
            
            let smallFrame = CGRectMake(15, cardShoeContainer!.bounds.size.height - 40, 60, 40)
            let smallFrameConverted = view.window!.rootViewController!.view!.convertRect(smallFrame, fromView: cardShoeContainer)
            cardViews[index].frame = smallFrameConverted
            
            view.window!.rootViewController!.view!.addSubview(cardViews[index])

            UIView.animateWithDuration(0.20, animations: {
                self.cardViews[index].frame = CGRectMake(smallFrameConverted.origin.x, smallFrameConverted.origin.y + 50, smallFrameConverted.size.width, smallFrameConverted.size.height)
                    }, completion: { _ in
                        UIView.animateWithDuration(0.20, delay: 0.0 , options: .CurveEaseOut, animations: {
                            self.cardViews[index].frame = cardShoeRect
                            self.pullCardFromShoe(self.cardViews[index])
                            }, completion: { _ in
                                UIView.transitionWithView(self.cardViews[index], duration: 0.15, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                                    self.cardViews[index].faceUp = true
                                    }, completion: { _ in
                                        let newIndex = index + 1
                                        self.revealRemainingCards(newIndex)
                                })
                
                        })
            })
        } else {
            // we are done with displaying the cards, now display the score label
            let label = UILabel()
            label.textAlignment = NSTextAlignment.Center
            label.text = self.dealerScoreText
//            println("dealerScore: \(self.dealerScoreText)")
            switch self.dealerScoreText {
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
            self.view.addSubview(label)
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                label.alpha = 1.0
                label.frame = CGRectMake(self.labelX!, 0, label.bounds.size.width, label.bounds.size.height)
                }, completion: { _ in
                    self.animating = false
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.dealerHandOver, object: nil)

//                    println("finished animating the gameover")
            })
        }
    }
    
   
}
