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

    var heightContraints: [NSLayoutConstraint] = []
    var widthContraints: [NSLayoutConstraint] = []
    var leftOffsetContraints: [NSLayoutConstraint] = []
    weak var cardShoeContainer: UIView?

    var holecardOffsetConstraint: NSLayoutConstraint?
    var requiredCardCenter: CGPoint?
    
    var cardWidthDivider: CGFloat = 3.0
    var numberOfCardsPerWidth: CGFloat = 4.0

    var isAnimatorOn = false
    var animator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var pushBehavior: UIPushBehavior?
    private var itemBehavior: UIDynamicItemBehavior?

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
        heightContraints.removeAll(keepCapacity: true)
        widthContraints.removeAll(keepCapacity: true)
        leftOffsetContraints.removeAll(keepCapacity: true)
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        cardViews = []
        animator?.removeAllBehaviors()
        animator = nil
        animating = false
        isAnimatorOn = false
    }

    func finishedAnimating() {
        
    }
    
    func finishedDynamicAnimating() {
        
    }

    func pullCardFromShoe(cardView: PlayingCardView) {
        if contains(cardViews, cardView) {
            if self.animator == nil {
                self.animator = UIDynamicAnimator(referenceView: self.view.window!.rootViewController!.view!)
                self.animator?.delegate = self
            }
            self.pushBehavior = UIPushBehavior(items: [cardView], mode: .Instantaneous)
            self.pushBehavior!.pushDirection = CGVectorMake(-0.2, 0.4)
            self.pushBehavior!.magnitude = 20
            self.animator!.addBehavior(self.pushBehavior)
            
            var myCenter: CGPoint?
            var holecard = false
            if let center = requiredCardCenter {
                println("Using the provided card center")
                myCenter = center
                cardView.tag = Int(numberOfCardsPerWidth)
                holecard = true
            } else {
                myCenter = view.convertPoint(cardView.center, toView: cardShoeContainer)
            }
            
            let point = self.view.convertPoint(myCenter!, toView: self.view.window!.rootViewController!.view!)
            
            self.snapBehavior = UISnapBehavior(item: cardView, snapToPoint: point)
            self.snapBehavior!.damping = 0.9
            self.animator!.addBehavior(self.snapBehavior)
            cardView.removeFromSuperview()
            self.view.addSubview(cardView)
            self.addConstraints(cardView, holeCard: holecard)
        } else {
            println("skipping this card display............\(NSDate())")
        }
    }

    func busyNow() ->Bool {
        if animating {
            return true
        }
        if let myAnimator = animator {
            if myAnimator.running {
                return true
            }
        }
        return false
    }

    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        isAnimatorOn = false
        animator.removeAllBehaviors()
        finishedDynamicAnimating()
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        isAnimatorOn = true
        
    }

    func addConstraints(cardView: PlayingCardView, holeCard: Bool = false) {
//        NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[top]-10-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let h1 = NSLayoutConstraint(item: cardView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: view.bounds.size.height)
        let w1 = NSLayoutConstraint(item: cardView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: view.bounds.size.width / cardWidthDivider)
        let t1 = NSLayoutConstraint(item: cardView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        
        let l1 = NSLayoutConstraint(item: cardView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: CGFloat(cardView.tag) * view.bounds.size.width /  (CGFloat(cardWidthDivider) * CGFloat(numberOfCardsPerWidth)))
        if holeCard {
            holecardOffsetConstraint = l1
        }
        h1.active = true
        t1.active = true
        w1.active = true
        l1.active = true
        heightContraints.append(h1)
        widthContraints.append(w1)
        leftOffsetContraints.append(l1)
        view.addConstraint(h1)
        view.addConstraint(w1)
        view.addConstraint(t1)
        view.addConstraint(l1)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        println("The new size of the dealer container .........is \(size)")
        println("size of the dealer container: \(view.frame)")
        
        //        view.setNeedsLayout()
        //        view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        println("Inside the view will layout subviews")
        println("size of the dealer container: \(view.frame)")
        for constraint in heightContraints {
            constraint.constant = view.bounds.size.height
        }
        for constraint in widthContraints {
            constraint.constant = view.bounds.size.width / cardWidthDivider
        }
        for (index,constraint) in enumerate(leftOffsetContraints) {
            constraint.constant = CGFloat(cardViews[index].tag) * view.bounds.size.width /  (CGFloat(cardWidthDivider) * CGFloat(numberOfCardsPerWidth))
            
        }
        
    }

}
