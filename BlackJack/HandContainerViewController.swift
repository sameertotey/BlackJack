//
//  HandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 3/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class HandContainerViewController: UIViewController, UIDynamicAnimatorDelegate {
    var cardViews: [PlayingCardView] = []
    var cards: [BlackjackCard] = []
    var displayCardQueue: [BlackjackCard] = []

    var heightConstraints: [NSLayoutConstraint] = []
    var widthConstraints: [NSLayoutConstraint] = []
    var leftOffsetConstraints: [NSLayoutConstraint] = []
    weak var cardShoeContainer: UIView?
    
    var label: UILabel?
    var labelConstraint: NSLayoutConstraint?
    var lastCardOffsetConstraint: NSLayoutConstraint?
    var labelDisplayNeeded = false

    var holecardOffsetConstraint: NSLayoutConstraint?
    var requiredCardCenter: CGPoint?
    
    var cardWidthDivider: CGFloat = 3.0
    var numberOfCardsPerWidth: CGFloat = 4.0

    var isAnimatorOn = false
    var animator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var pushBehavior: UIPushBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
    
    private var currentCardView: PlayingCardView?
    private var isHoleCard: Bool?
    
    
    var animating: Bool = false {
        didSet {
            if !animating {
                finishedAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reset() {
        heightConstraints.removeAll(keepingCapacity: false)
        widthConstraints.removeAll(keepingCapacity: false)
        leftOffsetConstraints.removeAll(keepingCapacity: false)
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        cardViews.removeAll()
        cards.removeAll(keepingCapacity: false)
        displayCardQueue.removeAll()
        labelDisplayNeeded = false
        label = nil
        animator?.removeAllBehaviors()
        animator = nil
        animating = false
        isAnimatorOn = false
    }

    func finishedAnimating() {
        
    }
    
    func finishedDynamicAnimating() {
        
    }

   func createCard(card: BlackjackCard) -> PlayingCardView {
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRect(x: xOffset, y: 0, width: cardWidth, height: self.view.bounds.height))
        playingCardView.translatesAutoresizingMaskIntoConstraints = false
        playingCardView.tag = cardViews.count
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
        cards.append(playingCardView.card)
        return playingCardView
    }
    
    func displayCard(playingCardView: PlayingCardView) {
        animating = true
        if cardShoeContainer != nil {
            let cardFrame = playingCardView.frame
            //            requiredCardCenter = playingCardView.center
            var cardShoeRect = view.convert(cardFrame, from: cardShoeContainer)
            
            let smallFrame = CGRect(x: 15, y: cardShoeContainer!.bounds.size.height - 40, width: 60, height: 40)
            let smallFrameConverted = view.window!.rootViewController!.view!.convert(smallFrame, from: cardShoeContainer)
            playingCardView.frame = smallFrameConverted
            self.view.window!.rootViewController!.view!.addSubview(playingCardView)
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                playingCardView.frame = CGRect(x: smallFrameConverted.origin.x, y: smallFrameConverted.origin.y + 50, width: smallFrameConverted.size.width, height: smallFrameConverted.size.height)
                }) { _ in
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                        playingCardView.frame = cardShoeRect
                        self.pullCardFromShoe(cardView: playingCardView)
                        }, completion: { _ in
                            UIView.transition(with: playingCardView, duration: 0.2, options: [.curveEaseOut, .transitionFlipFromLeft], animations: {
                                playingCardView.faceUp = true
                                }, completion: { _ in
                                    self.animating = false
                                    self.labelDisplayNeeded = true
                                }
                            )}
                    )}
        } else {
            view.addSubview(playingCardView)
            addConstraints(cardView: playingCardView, holeCard: false)
            playingCardView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                playingCardView.alpha = 1.0
                }, completion: {_ in
                    UIView.transition(with: playingCardView, duration: 0.3, options: [.curveEaseOut, .transitionFlipFromLeft], animations: {
                        playingCardView.faceUp = true
                        
                        }) { _ in
                            //
                            self.animating = false
                            self.labelDisplayNeeded = true
                    }
            })
        }
    }

    func pullCardFromShoe(cardView: PlayingCardView) {
        if cardViews.contains(cardView) {
            if self.animator == nil {
                self.animator = UIDynamicAnimator(referenceView: self.view.window!.rootViewController!.view!)
                self.animator?.delegate = self
            }
            self.pushBehavior = UIPushBehavior(items: [cardView], mode: .instantaneous)
            self.pushBehavior!.pushDirection = CGVector(dx: -0.2, dy: 0.4)
            self.pushBehavior!.magnitude = -0.1
            self.animator!.addBehavior(self.pushBehavior!)
            
            var myCenter: CGPoint?
            var holecard = false
            if let center = requiredCardCenter {
//                println("Using the provided card center")
                myCenter = center
                cardView.tag = Int(numberOfCardsPerWidth)
                holecard = true
            } else {
                myCenter = view.convert(cardView.center, to: cardShoeContainer)
            }
            
            let point = self.view.convert(myCenter!, to: self.view.window!.rootViewController!.view!)
            
            self.snapBehavior = UISnapBehavior(item: cardView, snapTo: point)
            self.snapBehavior!.damping = 0.9
            self.animator!.addBehavior(self.snapBehavior!)
            isHoleCard = holecard
            currentCardView = cardView
        } else {
//            println("skipping this card display............\(NSDate())")
        }
    }

    func busyNow() ->Bool {
        if animating {
            return true
        }
        if let myAnimator = animator {
            if myAnimator.isRunning {
                return true
            }
        }
        return false
    }

    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        currentCardView!.removeFromSuperview()
        self.view.addSubview(currentCardView!)
        self.addConstraints(cardView: currentCardView!, holeCard: isHoleCard!)
        isAnimatorOn = false
        animator.removeAllBehaviors()
        finishedDynamicAnimating()
    }
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        isAnimatorOn = true
        
    }

    func addConstraints(cardView: PlayingCardView, holeCard: Bool = false) {
//        NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[top]-10-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let h1 = NSLayoutConstraint(item: cardView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: view.bounds.size.height)
        let w1 = NSLayoutConstraint(item: cardView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: view.bounds.size.width / cardWidthDivider)
        let t1 = NSLayoutConstraint(item: cardView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        
        let l1 = NSLayoutConstraint(item: cardView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: CGFloat(cardView.tag) * view.bounds.size.width /  (CGFloat(cardWidthDivider) * CGFloat(numberOfCardsPerWidth)))
        if holeCard {
            holecardOffsetConstraint = l1
        }
        h1.isActive = true
        t1.isActive = true
        w1.isActive = true
        l1.isActive = true
        heightConstraints.append(h1)
        widthConstraints.append(w1)
        leftOffsetConstraints.append(l1)
        view.addConstraint(h1)
        view.addConstraint(w1)
        view.addConstraint(t1)
        view.addConstraint(l1)
    }
    
    func addLabelConstraints() {
        if let label = self.label {
            let t1 = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
            
            labelConstraint = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: CGRect(origin: self.cardViews[self.cardViews.count - 1].frame.origin, size: self.cardViews[self.cardViews.count - 1].frame.size).maxX)
            labelConstraint!.isActive = true
            t1.isActive = true
            view.addConstraint(labelConstraint!)
            view.addConstraint(t1)
        }
    }
    
    func updateLabelConstraint(constantValue: CGFloat) {
        if label != nil {
            labelConstraint?.constant =   constantValue
        }
    }
   
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for constraint in heightConstraints {
            constraint.constant = view.bounds.size.height
        }
        for constraint in widthConstraints {
            constraint.constant = view.bounds.size.width / cardWidthDivider
        }
        for (index,constraint) in leftOffsetConstraints.enumerated() {
            constraint.constant = CGFloat(cardViews[index].tag) * view.bounds.size.width /  (CGFloat(cardWidthDivider) * CGFloat(numberOfCardsPerWidth))
            lastCardOffsetConstraint = constraint
        }
        if lastCardOffsetConstraint != nil {
            updateLabelConstraint(constantValue: lastCardOffsetConstraint!.constant + view.bounds.size.width / cardWidthDivider)
        }
    }

}
