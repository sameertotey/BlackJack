//
//  GameAnimatedLabel.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/23/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

//
// Util delay function
//
func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

@IBDesignable
class GameAnimatedLabel: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var gradientLayer: CAGradientLayer = CAGradientLayer()
    @IBInspectable var label = UILabel()
    @IBInspectable var repeatCount: Float = 2.0
    @IBInspectable var duration: CFTimeInterval = 0.5
    @IBInspectable var labelBackground: UIColor?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let labelLayer = label.layer
        labelLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        labelLayer.backgroundColor = UIColor.clearColor().CGColor
        //set the background color
        let viewLayer = self.layer
        viewLayer.backgroundColor = UIColor.clearColor().CGColor
        clipsToBounds = true
        
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y, width: 3 * bounds.size.width, height: bounds.size.height)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        var colors: [AnyObject] = [
            UIColor.grayColor().CGColor,
            UIColor.greenColor().CGColor,
            UIColor.orangeColor().CGColor,
            UIColor.cyanColor().CGColor,
            UIColor.redColor().CGColor,
            UIColor.yellowColor().CGColor
        ]
        gradientLayer.colors = colors
        
        var locations: [AnyObject] = [
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0
        ]
        gradientLayer.locations = locations
        layer.insertSublayer(gradientLayer, atIndex: 0)
        layer.addSublayer(labelLayer)
    }
    
    func animateGradient() {
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.0, 0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.2, 0.33, 0.55, 0.70, 0.88, 1.0]
        gradientAnimation.duration = duration
        gradientAnimation.repeatCount = repeatCount
        gradientAnimation.removedOnCompletion = false
        gradientAnimation.fillMode = kCAFillModeRemoved
        
        gradientLayer.addAnimation(gradientAnimation, forKey: nil)
        
        if let backgroundColor = labelBackground {
            var delayInerval = duration as Double
            delayInerval = (repeatCount as NSNumber).doubleValue * delayInerval
            delay(seconds: delayInerval) {
                self.label.backgroundColor = backgroundColor
            }
        }
    }

    
}
