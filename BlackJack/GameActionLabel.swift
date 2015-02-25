//
//  GameActionLabel.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/24/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class GameActionLabel: MKLabel {

    override func sizeThatFits(size: CGSize) -> CGSize {
        let originalSize = super.sizeThatFits(self.frame.size)
        println("originalSize = \(originalSize)")
        return CGSizeMake(max(originalSize.width, originalSize.height) + 20, max(originalSize.width, originalSize.height) + 20)
    }
    
    override func drawRect(rect: CGRect) {
        
        let scaleFactor: CGFloat = 0.5
        let cornerRadius: CGFloat = 10.0
//        println("drawing the view with text \(self.text!)")
//        println("drawing the view with bounds \(self.bounds)")
//        let mysize = sizeThatFits(self.bounds.size)
//        println("mysize: \(mysize)")
        self.sizeToFit()
        
        println("drawing the view with bounds \(self.bounds)")

        let roundedRect = UIBezierPath(roundedRect:self.bounds, cornerRadius:cornerRadius)
//        roundedRect.addClip()
        UIColor.whiteColor().setFill()
        UIRectFill(self.bounds)
        println(self.bounds)
        println(self.frame)
        UIColor.blackColor().setStroke()
        roundedRect.stroke()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        
        var cornerFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cornerFont = cornerFont.fontWithSize(cornerFont.pointSize * scaleFactor)
        
        let cornerText = NSAttributedString(string: "\(self.text!)", attributes:[NSFontAttributeName : cornerFont, NSParagraphStyleAttributeName : paragraphStyle])
        
        var textBounds = CGRect()
        textBounds.origin = CGPointMake(10.0, 10.0)
        textBounds.size = cornerText.size()
        cornerText.drawInRect(textBounds)

        println("Ended drawing")

    }


}
