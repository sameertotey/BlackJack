//
//  GameActionLabel.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/24/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class GameActionLabel: MKLabel {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let originalSize = super.sizeThatFits(self.frame.size)
        return CGSize(x: max(originalSize.width, originalSize.height) + 20, width: max(originalSize.width, height: originalSize.height) + 20)
    }
    
    override func draw(_ rect: CGRect) {
        
        let scaleFactor: CGFloat = 0.5
        let cornerRadius: CGFloat = 10.0
//        println("drawing the view with text \(self.text!)")
//        println("drawing the view with bounds \(self.bounds)")
//        let mysize = sizeThatFits(self.bounds.size)
//        println("mysize: \(mysize)")
        self.sizeToFit()
        
//        println("drawing the view with bounds \(self.bounds)")

        let roundedRect = UIBezierPath(roundedRect:self.bounds, cornerRadius:cornerRadius)
//        roundedRect.addClip()
        UIColor.white.setFill()
        UIRectFill(self.bounds)
//        println(self.bounds)
//        println(self.frame)
        UIColor.black.setStroke()
        roundedRect.stroke()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var cornerFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        cornerFont = cornerFont.withSize(cornerFont.pointSize * scaleFactor)
        
        let cornerText = NSAttributedString(string: "\(self.text!)", attributes:[NSAttributedString.Key.font : cornerFont, NSAttributedString.Key.paragraphStyle : paragraphStyle])
        
        var textBounds = CGRect()
        textBounds.origin = CGPoint(x: 10.0, y: 10.0)
        textBounds.size = cornerText.size()
        cornerText.draw(in: textBounds)

//        println("Ended drawing")

    }


}
