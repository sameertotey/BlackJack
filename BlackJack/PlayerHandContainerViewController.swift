//
//  PlayerHandContainerViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class PlayerHandContainerViewController: UIViewController {
    private var cardViews: [PlayingCardView] = []
    private var playerScoreText = ""
    
    var cardWidthDivider: CGFloat = 3.0
    var numberOfCardsPerWidth: CGFloat = 4.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func reset() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        cardViews = []
        playerScoreText = ""
    }
    
    func addCardToPlayerHand(card: BlackjackCard) {
        println("added player card \(card)")
        displayCard(card)
    }
    
    func displayCard(card: BlackjackCard) {
        let cardWidth = CGFloat(self.view.bounds.width / cardWidthDivider)
        let xOffset = cardWidth * CGFloat(cardViews.count) / numberOfCardsPerWidth
        let playingCardView = PlayingCardView(frame: CGRectMake(0, 0, cardWidth, self.view.bounds.height))
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
        view.addSubview(playingCardView)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            playingCardView.frame = CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height)
            }, completion: {_ in
        UIView.transitionWithView(playingCardView, duration: 0.3, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
            playingCardView.faceUp = true

        }) { _ in
            //
            }
        })
    }
    
    func gameCompleted() {
     }
    
    func currentHandStatusUpdate(hand: BlackjackHand) {
        playerScoreText = hand.description
    }

    func removeLastCard() -> PlayingCardView? {
        if cardViews.count > 0 {
            let cardView = cardViews.removeLast()
            cardView.removeFromSuperview()
            return cardView
        } else {
            return nil
        }
    }
}
