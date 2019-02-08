//
//  GameAnimatedLabel.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/23/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

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
        labelLayer.backgroundColor = UIColor.clear.cgColor
        //set the background color
        let viewLayer = self.layer
        viewLayer.backgroundColor = UIColor.clear.cgColor
        clipsToBounds = true
        
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y, width: 3 * bounds.size.width, height: bounds.size.height)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors: [CGColor] = [
            UIColor.gray.cgColor,
            UIColor.green.cgColor,
            UIColor.orange.cgColor,
            UIColor.cyan.cgColor,
            UIColor.red.cgColor,
            UIColor.yellow.cgColor
        ]
        gradientLayer.colors = colors
        
        let locations: [NSNumber] = [
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0
        ]
        gradientLayer.locations = locations
        layer.insertSublayer(gradientLayer, at: 0)
        layer.addSublayer(labelLayer)
    }
    
    func animateGradient() {
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.0, 0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.2, 0.33, 0.55, 0.70, 0.88, 1.0]
        gradientAnimation.duration = duration
        gradientAnimation.repeatCount = repeatCount
        gradientAnimation.isRemovedOnCompletion = false
        gradientAnimation.fillMode = CAMediaTimingFillMode.removed
        
        gradientLayer.add(gradientAnimation, forKey: nil)
        
        if let backgroundColor = labelBackground {
            var delayInerval = duration as Double
            delayInerval = (repeatCount as NSNumber).doubleValue * delayInerval
            delay(seconds: delayInerval) {
                self.label.backgroundColor = backgroundColor
            }
        }
    }

    
}
