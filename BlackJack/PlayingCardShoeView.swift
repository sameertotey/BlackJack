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
        isOpaque = false
        contentMode = .redraw
//        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cardShoeLongPressed:")
//        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func sendNotification(message: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationMessages.setStatus), object: message)
    }
    

    func cardShoeLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            UIView.transition(with: self, duration: 0.25, options: [.curveEaseOut, .transitionFlipFromBottom], animations: {
                // send a message to get a new show
                }, completion: { _ in
                    self.sendNotification(message: "Getting a new Card Shoe")
                }
                    )
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
    override func draw(_ rect: CGRect) {
        
        let semiColor = UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 0.6)
        let sideColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)

        let roundedRect = UIBezierPath(roundedRect:self.bounds, cornerRadius:cornerRadius)
        roundedRect.addClip()
        UIColor.clear.setFill()
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
        let cardRect = CGRect(x: x2, y: bounds.height - ShoeConstants.cardHeight, width: ShoeConstants.cardWidth, height: ShoeConstants.cardHeight)
        UIImage(named: "cardback-red")?.draw(in: cardRect)
        
        // draw the shoe opening
        let openingPath = UIBezierPath()
        openingPath.move(to: CGPoint(x: x1, y: y1))
        openingPath.addLine(to: CGPoint(x: x1, y: y2))
        openingPath.addLine(to: CGPoint(x: x5, y: y2))
        openingPath.addLine(to: CGPoint(x: x5, y: y1))
        openingPath.addLine(to: CGPoint(x: x4 + 5.0, y: y1))

        openingPath.addArc(withCenter: CGPoint(x: 45, y: y1), radius: arcRadius, startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: false)

        openingPath.close()
        
        semiColor.setFill()
        UIColor.black.setStroke()
        openingPath.stroke()
        openingPath.fill()
        

        // draw the shoe top
        let topRectPath = UIBezierPath()
        topRectPath.move(to: CGPoint(x: x1, y: y2))
        topRectPath.addLine(to: CGPoint(x: x5, y: y2))
        topRectPath.addLine(to: CGPoint(x: bounds.width, y: y4))
        topRectPath.addLine(to: CGPoint(x: x3, y: y4))
        topRectPath.close()
        
        sideColor.setFill()
        UIColor.black.setStroke()
        topRectPath.stroke()
        topRectPath.fill()
        
        // draw the shoe side
        let sideRectPath = UIBezierPath()
        sideRectPath.move(to: CGPoint(x: x5, y: y1))
        sideRectPath.addLine(to: CGPoint(x: bounds.width, y: y3))
        sideRectPath.addLine(to: CGPoint(x: bounds.width, y: y4))
        sideRectPath.addLine(to: CGPoint(x: x5, y: y2))
        sideRectPath.close()
        
        sideColor.setFill()
        UIColor.black.setStroke()
        sideRectPath.stroke()
        sideRectPath.fill()
        
        drawText()
        
    }
    
    func drawText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textFont = textFont.withSize(textFont.pointSize * 0.6)
        
        let textText = NSAttributedString(string: "\(numDecks) Deck", attributes:[NSAttributedString.Key.font : textFont, NSAttributedString.Key.paragraphStyle : paragraphStyle])
        
        var textBounds = CGRect()
        textBounds.origin = CGPoint(x: 6, y: 6)
        textBounds.size = textText.size()
        textText.draw(in: textBounds)
        
    }

    
}
