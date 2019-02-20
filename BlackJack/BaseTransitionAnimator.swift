//
//  BaseTransitionAnimator.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BaseTransitionAnimator: NSObject {
    
    var duration = 0.5
    var presenting = true
    
    var initialScale: CGFloat = 0.001
    var finalScale: CGFloat = 1.0
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    // implement common methods here
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
}
