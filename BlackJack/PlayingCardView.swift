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
                AudioController.play(gameSound: .CardDraw)
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
        isOpaque = false
        contentMode = .redraw
        cornerScaleFactor = CGFloat (CGFloat(self.bounds.size.height) / CGFloat(cornerFixedFontStandardHeight))
        /*
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PlayingCardView", bundle: bundle)
        // Assumes UIView is top level and only object in PlayingCardView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        */
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "cardTapped:")
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector(("cardLongPressed:")))
        self.addGestureRecognizer(longPressGestureRecognizer)
    }

    func cardTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            UIView.transition(with: self, duration: 0.25, options: [.curveEaseOut, .transitionFlipFromLeft], animations: {
                self.faceUp = !self.faceUp
                }, completion: nil)
        }
    }
    
    func cardLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            UIView.transition(with: self, duration: 0.25, options: [.curveEaseOut, .transitionFlipFromLeft], animations: {
                self.faceUp = !self.faceUp
                }, completion: nil)
        }
    }

    // MARK: - initializers
       
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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
    override func draw(_ rect: CGRect) {

        let roundedRect = UIBezierPath(roundedRect:self.bounds, cornerRadius:cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        UIRectFill(self.bounds)
        UIColor.black.setStroke()
        roundedRect.stroke()
        
        if self.faceUp {
            if let fullCardImage = UIImage(named: "\(card.rank.shortDescription)\(card.suit.rawValue)") {
                fullCardImage.draw(in: bounds)
            } else {
                if let faceImage = UIImage(named: "Face-\(card.rank.shortDescription)\(card.suit.rawValue)") {
                    let imageRect = bounds.insetBy(dx: bounds.size.width * (1.0 - faceCardScaleFactor), dy: bounds.size.height * (1.0 - faceCardScaleFactor))
                    faceImage.draw(in: imageRect)
                } else {
                    drawAllPips()
                }
                drawCorners()
            }
        } else {
            UIImage(named: "cardback-red")?.draw(in: bounds)
        }
    }
    
    func drawCorners() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var cornerFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        cornerFont = cornerFont.withSize(cornerFont.pointSize * cornerScaleFactor)
        
        let cornerText = NSAttributedString(string: "\(card.rank.shortDescription)\n\(card.suit.rawValue)", attributes:[NSAttributedString.Key.font : cornerFont, NSAttributedString.Key.paragraphStyle : paragraphStyle])
        
        var textBounds = CGRect()
        textBounds.origin = CGPoint(x: cornerOffset, y: cornerOffset)
        textBounds.size = cornerText.size()
        cornerText.draw(in: textBounds)
        
        pushContextAndRotateUpsideDown()
        cornerText.draw(in: textBounds)
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

        if row1.contains(card.rank) {
            drawPips(horizontalOffset: 0, verticalOffset: 0, mirroredVertically: false)
        }
        
        if row2.contains(card.rank) {
            drawPips(horizontalOffset: pipHorizontalOffset, verticalOffset: 0, mirroredVertically: false)
        }
        
        if row3.contains(card.rank) {
            drawPips(horizontalOffset: 0, verticalOffset: pipVerticalOffset2, mirroredVertically: card.rank != .Seven)
        }

        if row4.contains(card.rank) {
            drawPips(horizontalOffset: pipHorizontalOffset, verticalOffset: pipVerticalOffset3, mirroredVertically: true)
        }
        
        if row5.contains(card.rank) {
            drawPips(horizontalOffset: pipHorizontalOffset, verticalOffset: pipVerticalOffset1, mirroredVertically: true)
        }

        
    }
    
    func drawPips(horizontalOffset: CGFloat, verticalOffset: CGFloat, mirroredVertically: Bool) {
        switch (mirroredVertically) {
        case true:
            drawPip(horizontalOffset, verticalOffset, true)
            fallthrough
        default:
            drawPip(horizontalOffset, verticalOffset, false)
        }
    }
    
    
    func drawPip(_ horizontalOffset: CGFloat, _ verticalOffset: CGFloat, _ upsideDown: Bool) {
        let pipFontScaleFactor: CGFloat = 0.012

        if upsideDown {
            pushContextAndRotateUpsideDown()
        }
        
        let middle = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        var pipFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        pipFont = pipFont.withSize(pipFont.pointSize * bounds.size.width * pipFontScaleFactor)
        let attributedSuit = NSAttributedString(string: card.suit.rawValue, attributes: [NSAttributedString.Key.font: pipFont])
        let pipSize = attributedSuit.size()
        var pipOrigin = CGPoint(x: middle.x - pipSize.width / 2.0 - horizontalOffset * bounds.size.width, y: middle.y - pipSize.height / 2.0 - verticalOffset * bounds.size.height)
        attributedSuit.draw(at: pipOrigin)
        
        if horizontalOffset > 0 {
            pipOrigin.x += horizontalOffset * 2.0 * bounds.size.width
            attributedSuit.draw(at: pipOrigin)
        }
        
        if upsideDown {
            popContext()
        }

    }

    
    func pushContextAndRotateUpsideDown() {
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        context!.translateBy(x: bounds.size.width, y: bounds.size.height)
        context!.rotate(by: CGFloat(Double.pi))
    }
    
    func popContext() {
        UIGraphicsGetCurrentContext()!.restoreGState()
    }

}


