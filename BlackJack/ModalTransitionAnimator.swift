//
//  ModalTransitionAnimator.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ModalTransitionAnimator: BaseTransitionAnimator, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // all animations take place here, force unwrap the view controller
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
                
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        if presenting {
            fromViewController.view.isUserInteractionEnabled = false
            toViewController.view.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
            toViewController.view.layer.shadowColor = UIColor.black.cgColor
            toViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            toViewController.view.layer.shadowOpacity = 0.3
            toViewController.view.layer.cornerRadius = 4.0
            toViewController.view.clipsToBounds = true
            
            containerView.addSubview(toViewController.view)
            
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                toViewController.view.transform = CGAffineTransform(scaleX: self.finalScale, y: self.finalScale)
                containerView.addSubview(toViewController.view)
                fromViewController.view.alpha = 0.5
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })

        } else {
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                fromViewController.view.transform = CGAffineTransform(scaleX: self.initialScale, y: self.initialScale)
                toViewController.view.alpha = 1.0
                }, completion: { (finished) -> Void in
                    toViewController.view.isUserInteractionEnabled = true
                    fromViewController.view.removeFromSuperview()
                    transitionContext.completeTransition(finished)
            })

        }
        
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        // cleanup after animation ended
    }
    
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return super.transitionDuration(using: transitionContext)
    }
}
