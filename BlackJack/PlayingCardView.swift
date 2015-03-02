//
//  PlayingCardView.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/5/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    
    @IBInspectable var textColor: UIColor?

    @IBInspectable var faceCardScaleFactor: CGFloat = 0.90
    var card: BlackjackCard! {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var faceUp: Bool = false {
        didSet {
            setNeedsDisplay()
            if faceUp != oldValue {
                AudioController.play(.CardDraw)   
            }
        }
    }

    
    let cornerFixedFontStandardHeight = 180.0
    let cornerFixedRadius = 6.0
    
    var cornerScaleFactor: CGFloat! = 0.8
    var cornerRadius: CGFloat {  return CGFloat(cornerFixedRadius) * CGFloat(cornerScaleFactor) }
    var cornerOffset: CGFloat {  return cornerRadius / 3.0 }
    
    func setup () {
        backgroundColor = nil
        opaque = false
        contentMode = .Redraw
        cornerScaleFactor = CGFloat (CGFloat(self.bounds.size.height) / CGFloat(cornerFixedFontStandardHeight))
        /*
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PlayingCardView", bundle: bundle)
        // Assumes UIView is top level and only object in PlayingCardView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "cardTapped:")
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    func cardTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            // handling code
            UIView.transitionWithView(self, duration: 0.25, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
                self.faceUp = !self.faceUp
            }, completion: nil)
        }
    }

    // MARK: - initializers
    override init() {
        super.init()
        setup()
        
    }
    
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
    
    // MARK: - drawing
    override func drawRect(rect: CGRect) {

        let roundedRect = UIBezierPath(roundedRect:self.bounds, cornerRadius:cornerRadius)
        roundedRect.addClip()
        UIColor.whiteColor().setFill()
        UIRectFill(self.bounds)
        UIColor.blackColor().setStroke()
        roundedRect.stroke()
        
        if self.faceUp {
            if let fullCardImage = UIImage(named: "\(card.rank.shortDescription)\(card.suit.rawValue)") {
                fullCardImage.drawInRect(bounds)
            } else {
                if let faceImage = UIImage(named: "Face-\(card.rank.shortDescription)\(card.suit.rawValue)") {
                    let imageRect = CGRectInset(bounds, bounds.size.width * (1.0 - faceCardScaleFactor), bounds.size.height * (1.0 - faceCardScaleFactor))
                    faceImage.drawInRect(imageRect)
                } else {
                    drawAllPips()
                }
                drawCorners()
            }
        } else {
            UIImage(named: "cardback-red")?.drawInRect(bounds)
        }
    }
    
    func drawCorners() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        
        var cornerFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cornerFont = cornerFont.fontWithSize(cornerFont.pointSize * cornerScaleFactor)
        
        let cornerText = NSAttributedString(string: "\(card.rank.shortDescription)\n\(card.suit.rawValue)", attributes:[NSFontAttributeName : cornerFont, NSParagraphStyleAttributeName : paragraphStyle])
        
        var textBounds = CGRect()
        textBounds.origin = CGPointMake(cornerOffset, cornerOffset)
        textBounds.size = cornerText.size()
        cornerText.drawInRect(textBounds)
        
        pushContextAndRotateUpsideDown()
        cornerText.drawInRect(textBounds)
        popContext()
    }

   
    func drawAllPips() {
        let pipHorizontalOffset: CGFloat = 0.165
        let pipVerticalOffset1: CGFloat  = 0.090
        let pipVerticalOffset2: CGFloat  = 0.175
        let pipVerticalOffset3: CGFloat  = 0.27

        let row1 = [BlackjackCard.Rank.Ace, .Five, .Nine, .Three]
        let row2 = [BlackjackCard.Rank.Six, .Seven, .Eight]
        let row3 = [BlackjackCard.Rank.Two, .Three, .Seven, .Eight, .Ten]
        let row4 = [BlackjackCard.Rank.Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten]
        let row5 = [BlackjackCard.Rank.Nine, .Ten]

        if contains(row1, card.rank) {
            drawPips(horizontalOffset: 0, verticalOffset: 0, mirroredVertically: false)
        }
        
        if contains(row2, card.rank) {
            drawPips(horizontalOffset: pipHorizontalOffset, verticalOffset: 0, mirroredVertically: false)
        }
        
        if contains(row3, card.rank) {
            drawPips(horizontalOffset: 0, verticalOffset: pipVerticalOffset2, mirroredVertically: card.rank != .Seven)
        }

        if contains(row4, card.rank) {
            drawPips(horizontalOffset: pipHorizontalOffset, verticalOffset: pipVerticalOffset3, mirroredVertically: true)
        }
        
        if contains(row5, card.rank) {
            drawPips(horizontalOffset: pipHorizontalOffset, verticalOffset: pipVerticalOffset1, mirroredVertically: true)
        }

        
    }
    
    func drawPips(#horizontalOffset: CGFloat, verticalOffset: CGFloat, mirroredVertically: Bool) {
        switch (mirroredVertically) {
        case true:
            drawPip(horizontalOffset, verticalOffset, true)
            fallthrough
        default:
            drawPip(horizontalOffset, verticalOffset, false)
        }
    }
    
    
    func drawPip(horizontalOffset: CGFloat, _ verticalOffset: CGFloat, _ upsideDown: Bool) {
        let pipFontScaleFactor: CGFloat = 0.012

        if upsideDown {
            pushContextAndRotateUpsideDown()
        }
        
        let middle = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0)
        var pipFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        pipFont = pipFont.fontWithSize(pipFont.pointSize * bounds.size.width * pipFontScaleFactor)
        let attributedSuit = NSAttributedString(string: card.suit.rawValue, attributes: [NSFontAttributeName: pipFont])
        let pipSize = attributedSuit.size()
        var pipOrigin = CGPointMake(middle.x - pipSize.width / 2.0 - horizontalOffset * bounds.size.width, middle.y - pipSize.height / 2.0 - verticalOffset * bounds.size.height)
        attributedSuit.drawAtPoint(pipOrigin)
        
        if horizontalOffset > 0 {
            pipOrigin.x += horizontalOffset * 2.0 * bounds.size.width
            attributedSuit.drawAtPoint(pipOrigin)
        }
        
        if upsideDown {
            popContext()
        }

    }

    
    func pushContextAndRotateUpsideDown() {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, bounds.size.width, bounds.size.height)
        CGContextRotateCTM(context, CGFloat(M_PI))
    }
    
    func popContext() {
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
    }

}


