//
//  PlayerHandViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class PlayerHandViewController: UIViewController {
    private var cardViews: [PlayingCardView] = []
    private var playerScoreText = ""
    
    private let cardWidthDivider: CGFloat = 3.0
    private let numberOfCardsPerWidth: CGFloat = 4.0
    
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
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, self.view.bounds.height))
        playingCardView.card = card
        playingCardView.faceUp = false
        cardViews.append(playingCardView)
    }
    
    func gameCompleted() {
     }
    

}
