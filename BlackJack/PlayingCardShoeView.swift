//
//  PlayingCardShoeView.swift
//  BlackJack
//
//  Created by Sameer Totey on 3/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardShoeView: UIView {
    @IBInspectable var textColor: UIColor?
    @IBInspectable var background: UIColor?
    @IBInspectable var cornerRadius: CGFloat = 3.0
    
    @IBInspectable var currentPenetration: CGFloat = 0.90 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var maxPenetration: CGFloat = 0.25 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var numDecks: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func setup () {
        backgroundColor = nil
        opaque = false
        contentMode = .Redraw
//        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cardShoeLongPressed:")
//        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func sendNotification(message: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.setStatus, object: message)
    }
    

    func cardShoeLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .Ended {
            // handling code
            UIView.transitionWithView(self, duration: 0.25, options: .CurveEaseOut | .TransitionFlipFromBottom, animations: {
                // send a message to get a new show
                }, completion: { _ in
                    self.sendNotification("Getting a new Card Shoe")
                }
                    )
        }
    }
    
    // MARK: - initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    struct ShoeConstants {
        static let cardWidth: CGFloat = 60.0
        static let cardHeight: CGFloat = 40.0
        static let boxPadding: CGFloat = 5.0
        static let boxXOffset: CGFloat = 10.0
        static let boxYOffset: CGFloat = 10.0
        static let boxArcOffset: CGFloat = 15.0
        static let boxArcRadius: CGFloat = 30.0
    }
    // MARK: - drawing
    override func drawRect(rect: CGRect) {
        
        let semiColor = UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 0.6)
        let sideColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)

        let roundedRect = UIBezierPath(roundedRect:self.bounds, cornerRadius:cornerRadius)
        roundedRect.addClip()
        UIColor.clearColor().setFill()
        UIRectFill(self.bounds)
        
        // draw the card
        let x1 = ShoeConstants.boxXOffset
        let x2 = x1 + ShoeConstants.boxPadding
        let x3 = x2 + ShoeConstants.boxArcOffset
        let x4 = x3 + ShoeConstants.boxArcRadius
        let x5 = x4 + ShoeConstants.boxArcOffset + ShoeConstants.boxPadding
        
        let y1 = bounds.height - ShoeConstants.boxYOffset
        let y2 = y1 - ShoeConstants.cardHeight - ShoeConstants.boxPadding
        let y3 = y1 - 25.0
        let y4 = y2 - 25.0
        
        let arcRadius: CGFloat = 20.0
        
        // draw the dummy card
        let cardRect = CGRectMake(x2, bounds.height - ShoeConstants.cardHeight, ShoeConstants.cardWidth, ShoeConstants.cardHeight)
        UIImage(named: "cardback-red")?.drawInRect(cardRect)
        
        // draw the shoe opening
        let openingPath = UIBezierPath()
        openingPath.moveToPoint(CGPointMake(x1, y1))
        openingPath.addLineToPoint(CGPointMake(x1, y2))
        openingPath.addLineToPoint(CGPointMake(x5, y2))
        openingPath.addLineToPoint(CGPointMake(x5, y1))
        openingPath.addLineToPoint(CGPointMake(x4 + 5.0, y1))

        openingPath.addArcWithCenter(CGPointMake(45, y1), radius: arcRadius, startAngle: 0, endAngle: CGFloat(M_PI), clockwise: false)

        openingPath.closePath()
        
        semiColor.setFill()
        UIColor.blackColor().setStroke()
        openingPath.stroke()
        openingPath.fill()
        

        // draw the shoe top
        let topRectPath = UIBezierPath()
        topRectPath.moveToPoint(CGPointMake(x1, y2))
        topRectPath.addLineToPoint(CGPointMake(x5, y2))
        topRectPath.addLineToPoint(CGPointMake(bounds.width, y4))
        topRectPath.addLineToPoint(CGPointMake(x3, y4))
        topRectPath.closePath()
        
        sideColor.setFill()
        UIColor.blackColor().setStroke()
        topRectPath.stroke()
        topRectPath.fill()
        
        // draw the shoe side
        let sideRectPath = UIBezierPath()
        sideRectPath.moveToPoint(CGPointMake(x5, y1))
        sideRectPath.addLineToPoint(CGPointMake(bounds.width, y3))
        sideRectPath.addLineToPoint(CGPointMake(bounds.width, y4))
        sideRectPath.addLineToPoint(CGPointMake(x5, y2))
        sideRectPath.closePath()
        
        sideColor.setFill()
        UIColor.blackColor().setStroke()
        sideRectPath.stroke()
        sideRectPath.fill()
        
        drawText()
        
    }
    
    func drawText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        
        var textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textFont = textFont.fontWithSize(textFont.pointSize * 0.6)
        
        let textText = NSAttributedString(string: "\(numDecks) Deck", attributes:[NSFontAttributeName : textFont, NSParagraphStyleAttributeName : paragraphStyle])
        
        var textBounds = CGRect()
        textBounds.origin = CGPointMake(6, 6)
        textBounds.size = textText.size()
        textText.drawInRect(textBounds)
        
    }

    
}
