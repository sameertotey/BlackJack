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
                holeCardView!.isUserInteractionEnabled = true
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
                let playingCardView = createCard(card: displayCardQueue.remove(at: 0))
                displayCard(playingCardView: playingCardView)
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
        upCardView = createCard(card: card)
        animating = true
        let cardFrame = upCardView!.frame
        let cardShoeRect = view.convert(cardFrame, from: cardShoeContainer)
        
        let smallFrame = CGRect(x:15, y:cardShoeContainer!.bounds.size.height - 40, width:60, height:40)
        let smallFrameConverted = view.window!.rootViewController!.view!.convert(smallFrame, from: cardShoeContainer)
        upCardView!.frame = smallFrameConverted
        self.view.window!.rootViewController!.view!.addSubview(upCardView!)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.upCardView!.frame = CGRect(x:smallFrameConverted.origin.x, y:smallFrameConverted.origin.y + 50, width:smallFrameConverted.size.width, height:smallFrameConverted.size.height)
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                    self.upCardView!.frame = cardShoeRect
                    self.pullCardFromShoe(cardView: self.upCardView!)
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
        holeCardView = createCard(card: holeCard!)
        holeCardView!.isUserInteractionEnabled = false
        originalHoleCardFrame = holeCardView!.frame
        
        let newFrame = CGRect(x:self.view.bounds.width / cardWidthDivider, y:0, width:self.view.bounds.width / cardWidthDivider, height:self.view.bounds.height)
        holeCardView!.frame = newFrame

        
        let holeCardCenter = holeCardView!.center
        
        let cardFrame = upCardView!.frame
        let cardShoeRect = view.convert(cardFrame, from: cardShoeContainer)
        
        let smallFrame = CGRect(x:15, y:cardShoeContainer!.bounds.size.height - 40, width:60, height:40)
        let smallFrameConverted = view.window!.rootViewController!.view!.convert(smallFrame, from: cardShoeContainer)
        holeCardView!.frame = smallFrameConverted
        self.requiredCardCenter = holeCardCenter
        self.view.window!.rootViewController!.view!.addSubview(self.holeCardView!)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut , animations: {
            self.holeCardView!.frame = CGRect(x:smallFrameConverted.origin.x, y:smallFrameConverted.origin.y + 50, width:smallFrameConverted.size.width, height:smallFrameConverted.size.height)
            }, completion: { _ in
                UIView.animate( withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                    self.holeCardView!.frame = cardShoeRect
                    self.pullCardFromShoe(cardView: self.holeCardView!)
                    }, completion: { _ in
                        self.requiredCardCenter = nil
                        UIView.transition(with: self.upCardView!, duration: 0.3, options: [.curveEaseOut , .transitionFlipFromLeft], animations: {
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
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut , animations: {
            self.holeCardView!.frame = self.originalHoleCardFrame!
            }, completion: { _ in
                UIView.transition(with: self.holeCardView!, duration: 0.2, options: [.curveEaseOut , .transitionFlipFromLeft], animations: {
                    self.holeCardView!.faceUp = true
                    }, completion: { _ in
//                        self.revealRemainingCards(2)
                        self.labelDisplayNeeded = true
                        self.animating = false
                })
        })
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
            label!.text = self.dealerScoreText
            switch self.dealerScoreText {
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
            label!.frame = CGRect(x:0, y:0, width:label!.bounds.size.width, height:label!.bounds.size.height)
            let myX = self.cardViews[self.cardViews.count - 1].frame.maxX
            self.view.addSubview(label!)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.label!.alpha = 1.0
                self.label!.frame = CGRect(x:myX, y:0, width:self.label!.bounds.size.width, height:self.label!.bounds.size.height)
                }, completion: { _ in
                    self.addLabelConstraints()
                    self.view.window!.rootViewController!.view!.isUserInteractionEnabled = true
                    self.animating = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationMessages.dealerHandOver), object: nil)
            })
            labelDisplayNeeded = false
        }
    }

}
