//
//  ModalTransitionAnimator.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ModalTransitionAnimator: BaseTransitionAnimator, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // all animations take place here, force unwrap the view controller
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
                
        let containerView = transitionContext.containerView()
        
        let animationDuration = transitionDuration(transitionContext)
        
        if presenting {
            fromViewController.view.userInteractionEnabled = false
            toViewController.view.transform = CGAffineTransformMakeScale(initialScale, initialScale)
            toViewController.view.layer.shadowColor = UIColor.blackColor().CGColor
            toViewController.view.layer.shadowOffset = CGSizeMake(0.0, 2.0)
            toViewController.view.layer.shadowOpacity = 0.3
            toViewController.view.layer.cornerRadius = 4.0
            toViewController.view.clipsToBounds = true
            
            containerView.addSubview(toViewController.view)
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                toViewController.view.transform = CGAffineTransformMakeScale(self.finalScale, self.finalScale)
                containerView.addSubview(toViewController.view)
                fromViewController.view.alpha = 0.5
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })

        } else {
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                fromViewController.view.transform = CGAffineTransformMakeScale(self.initialScale, self.initialScale)
                toViewController.view.alpha = 1.0
                }, completion: { (finished) -> Void in
                    toViewController.view.userInteractionEnabled = true
                    fromViewController.view.removeFromSuperview()
                    transitionContext.completeTransition(finished)
            })

        }
        
    }
    
    func animationEnded(transitionCompleted: Bool) {
        // cleanup after animation ended
    }
    
      
}
