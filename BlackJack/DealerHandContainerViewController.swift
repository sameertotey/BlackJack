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
    private var theRootView: UIView?
    private var requiredCardCenter: CGPoint?
    private var labelX: CGFloat?
    
    private var upCardView: PlayingCardView?
    private var holeCardView: PlayingCardView?
    
    private var dealerScoreText = ""
    
    private let cardWidthDivider: CGFloat = 3.0
    private let numberOfCardsPerWidth: CGFloat = 4.0
    
    weak var cardShoeContainer: UIView?
    private var animator: UIDynamicAnimator? 
    private var snapBehavior: UISnapBehavior?
    private var pushBehavior: UIPushBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func currentDealerHandUpdate(hand: BlackjackHand) {
        dealerScoreText = hand.valueDescription
    }
    
    func flipHoleCard() {
        holeCardView!.userInteractionEnabled = true
    }
    
    func reset() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        cardViews = []
        upCardView = nil
        holeCardView = nil
        dealerScoreText = ""
        self.animator?.removeAllBehaviors()
    }
    
    func addCardToDealerHand(card: BlackjackCard) {
        println("added dealer card \(card)")
        createCard(card)
    }
    
    func pullCardFromShoe(cardView: PlayingCardView) {
        if self.animator == nil {
            self.animator = UIDynamicAnimator(referenceView: self.theRootView!)
        }
        self.pushBehavior = UIPushBehavior(items: [cardView], mode: .Instantaneous)
        self.pushBehavior!.pushDirection = CGVectorMake(-0.2, 0.4)
        self.pushBehavior!.magnitude = 20
        self.animator!.addBehavior(self.pushBehavior)
        
        let point = self.view.convertPoint(self.requiredCardCenter!, toView: self.theRootView)
        
        self.snapBehavior = UISnapBehavior(item: cardView, snapToPoint: point)
        self.animator!.addBehavior(self.snapBehavior)
        cardView.removeFromSuperview()
        self.view.addSubview(cardView)
        println("displaying card \(cardView.card)")

    }
    
    func addUpCardToDealerHand(card: BlackjackCard) {
        println("added dealer up card \(card)")
        createCard(card)
        upCardView = cardViews[0]
        upCardView!.faceUp = false
    }
    

    func displayInitialCards() {
        self.theRootView = self.view.window!.rootViewController!.view!
        
        let cardFrame = upCardView!.frame
        requiredCardCenter = upCardView!.center
        var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
        
        let smallFrame = CGRectMake(0, cardShoeContainer!.bounds.size.height - 20, 10, 20)
        let smallFrameConverted = theRootView!.convertRect(smallFrame, fromView: cardShoeContainer)
        upCardView!.frame = smallFrameConverted
        let holeCardCenter = holeCardView!.center
        holeCardView!.frame = smallFrameConverted
        theRootView!.addSubview(upCardView!)

        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.upCardView!.frame = cardShoeRect
            }) { _ in
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.pullCardFromShoe(self.upCardView!)
                    }, completion: { _ in
                        self.requiredCardCenter = holeCardCenter
                        self.theRootView!.addSubview(self.holeCardView!)
                        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut , animations: {
                              self.holeCardView!.frame = cardShoeRect
                            }, completion: { _ in
                                UIView.animateWithDuration( 0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                                    self.pullCardFromShoe(self.holeCardView!)
                                    }, completion: { _ in
                                        UIView.transitionWithView(self.upCardView!, duration: 0.3, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                                        self.upCardView!.faceUp = true
                                        }, completion: nil)}
                                )}
                        )}
                )}
    }
    
    func addHoleCardToDealerHand(card: BlackjackCard) {
        println("added dealer hole card \(card)")
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
    
    func createCard(card: BlackjackCard) {
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height))
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
    }
    
    func gameCompleted() {
        println("game over")
        theRootView?.userInteractionEnabled = false
        animator?.removeAllBehaviors()

        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut , animations: {
            //
            self.holeCardView!.frame = self.originalHoleCardFrame!
            }, completion: { _ in
                UIView.transitionWithView(self.holeCardView!, duration: 0.2, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                    self.labelX = CGRectGetMaxX(self.cardViews[self.cardViews.count - 1].frame)
                    self.holeCardView!.faceUp = true
                    }, completion: { _ in
                        self.revealRemainingCards(2)
                        self.theRootView?.userInteractionEnabled = true
                })
        } )
    }

    func revealRemainingCards(index:Int) {
        if index < cardViews.count {
            theRootView = self.view.window!.rootViewController!.view!
            let cardFrame = cardViews[index].frame
            requiredCardCenter = cardViews[index].center
            var cardShoeRect = view.convertRect(cardFrame, fromView: cardShoeContainer)
            
            let smallFrame = CGRectMake(0, cardShoeContainer!.bounds.size.height - 20, 10, 20)
            let smallFrameConverted = theRootView!.convertRect(smallFrame, fromView: cardShoeContainer)
            cardViews[index].frame = smallFrameConverted
            
            theRootView!.addSubview(cardViews[index])

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
        } else {
            // we are done with displaying the cards, now display the score label
            let label = UILabel()
            label.textAlignment = NSTextAlignment.Center
            label.text = self.dealerScoreText
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
            })
        }
    }
    
}
