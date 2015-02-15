//
//  BlackjackGameViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BlackjackGameViewController: UIViewController, CardPlayerObserver, DealerObserver {
    
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()
    
    var blackjackGame: BlackjackGame!
    var currentPlayer: Player!
    var gameConfiguraton: GameConfiguration!
    var theDealer: Dealer!
    var currentBet: Double = 0.0 {
        didSet {
            currenBetLabel.text = "\(currentBet)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameConfiguraton = GameConfiguration()
        blackjackGame = BlackjackGame()
        blackjackGame.gameConfiguration = gameConfiguraton
        
        currentPlayer = Player(name: "Sameer")
        currentPlayer.observer = self
        currentPlayer.bankRoll = 100.00
        currentPlayer.delegate = blackjackGame
        playerBankRollLabel.text = "\(currentPlayer.bankRoll)"
        theDealer = Dealer()
        theDealer.gameConfiguration = gameConfiguraton
        theDealer.cardSource = blackjackGame
        theDealer.observer = self
        blackjackGame.dealer = theDealer
        
//        setupButtons()
        blackjackGame.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    /*
    Normally an unwind segue will pop/dismiss the view controller but this doesn't happen
    for custom modal transitions so we have to manually call dismiss.
    */
    
    @IBAction func returnToGameViewController(segue:UIStoryboardSegue) {
        // return here from game configuration using unwind segue
        if (segue.identifier == "CancelFromConfiguration") || (segue.identifier == "SaveFromConfiguration") {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Present Game Configuration" {
            if segue.destinationViewController is UINavigationController {
                let toVC = segue.destinationViewController as UINavigationController
                toVC.modalPresentationStyle = .Custom
                toVC.transitioningDelegate = self.modalTransitioningDelegate
            }

        }
    }
    
    // MARK: - Gesture Recognizers
    
    @IBOutlet weak var dealerContainerView: UIView!
    var dealerCardViews: [PlayingCardView] = []
    @IBOutlet weak var playerContainerView: UIView!
    var currentPlayerViews: [PlayingCardView] = []
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    @IBOutlet weak var dealerScoreLabel: UILabel!
    
    @IBOutlet weak var playerBankRollLabel: UILabel!
    @IBOutlet weak var doubleDownButton: UIButton!
    @IBOutlet weak var currenBetLabel: UILabel!
    
    @IBOutlet weak var splitHandButton: UIButton!
    @IBOutlet weak var surrenderButton: UIButton!
    
    @IBOutlet weak var buyInsuranceButton: UIButton!
    
    @IBOutlet weak var declineInsuranceButton: UIButton!
    
    @IBOutlet var finishedHandContainerViews: [UIView]!
    var finishedHandViews: [[PlayingCardView]] = []
    
    @IBOutlet var splitHandContainerViews: [UIView]!
    var splitHandViews: [PlayingCardView] = []       // There is only one card per split hand view
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var standButton: UIButton!
    
    // Actions
    
    func setupButtons() {
        while currentBet <= gameConfiguraton.minimumBet {
            statusLabel.text = "Minimum bet: \(gameConfiguraton.minimumBet)"
            doubleDownButton.hidden = true
            splitHandButton.hidden = true
            surrenderButton.hidden = true
            buyInsuranceButton.hidden = true
            declineInsuranceButton.hidden = true
            betButton.hidden = false
            dealButton.hidden = true
            hitButton.hidden = true
            standButton.hidden = true
        }

    }
    
    @IBAction func dealButtonTouchUpInside(sender: UIButton) {
        if blackjackGame.gameState == .Deal && currentPlayer.bet(currentBet){
            resetCardViews()
            blackjackGame.deal()
            blackjackGame.update()
        }
    }
    
    func resetCardViews() {
        // remove old cards from the view
        for view in playerContainerView.subviews {
            if view is PlayingCardView {
                view.removeFromSuperview()
            }
        }
        currentPlayerViews.removeAll(keepCapacity: true)
        for view in dealerContainerView.subviews {
            if view is PlayingCardView {
                view.removeFromSuperview()
            }
        }
        dealerCardViews.removeAll(keepCapacity: true)
        dealerScoreLabel.hidden = true
        //            doubleDownButton.hidden = true
        for viewContainer in finishedHandContainerViews {
            for view in viewContainer.subviews {
                if view is PlayingCardView {
                    view.removeFromSuperview()
                }
            }
        }
        finishedHandViews.removeAll(keepCapacity: true)
    }
    
    func displayPlayerCard(card: BlackjackCard, index: Int) {
        println("player index \(index)")
        let xOffset = CGFloat(10 + 50 * index)
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, 90, 150))
        playingCardView.faceUp = true
        playingCardView.card = card
        playerContainerView.addSubview(playingCardView)
        currentPlayerViews.insert(playingCardView, atIndex: index)
    }
    
    func displayDealerCard(card: BlackjackCard, faceup: Bool, index: Int) {
        println("dealer index \(index)")
        let xOffset = CGFloat(10 + 50 * index)
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, 90, 150))
        playingCardView.faceUp = faceup
        playingCardView.card = card
        dealerContainerView.addSubview(playingCardView)
        dealerCardViews.insert(playingCardView, atIndex: index)
    }
    
    @IBAction func hitButtonTouchUpInside(sender: UIButton) {
        currentPlayer.hit()
//        setupButtons()
    }
    
    @IBAction func standButtonTouchUpInside(sender: UIButton) {
        currentPlayer.stand()
    }
    
    @IBAction func doubleButtonTouchUpInside(sender: UIButton) {
        currentPlayer.doubleDown()
    }

    @IBAction func splitHandButtonTouchUpInside(sender: UIButton) {
        currentPlayer.split()
    }
    
    @IBAction func surrenderButtonTouchUpInside(sender: UIButton) {
        currentPlayer.surrenderHand()
    }
    
    @IBAction func buyInsuranceButtonTouchUpInside(sender: UIButton) {
        currentPlayer.buyInsurance()
    }
    
    @IBAction func declineInsuranceButtonTouchUpInside(sender: UIButton) {
        currentPlayer.declineInsurance()

    }
    
    @IBAction func betButtonTouchUpInside(sender: UIButton) {
        // add logic to alter bets lated
        currentBet = gameConfiguraton.minimumBet
    }
    // MARK: - Card Player Observer
    
    func currentHandStatusUpdate(hand: BlackjackHand) {
        playerScoreLabel.text = hand.valueDescription
    }
    
    func addCardToCurrentHand(card: BlackjackCard)  {
        println("add \(card)")
        displayPlayerCard(card, index: currentPlayer.currentHand!.cards.count - 1)
    }
    
    func addnewlySplitHand(card: BlackjackCard) {
        var cardView = currentPlayerViews.removeLast()
        cardView.removeFromSuperview()
        cardView.frame = CGRectMake(0, 0, 40, 60)
        let splitHandsCount = splitHandViews.count
        splitHandContainerViews[splitHandsCount].addSubview(cardView)
        splitHandViews.insert(cardView, atIndex: splitHandsCount)
    }
    
    func switchHands() {
        println("Advance to next hand....")
        let finishedHandsCount = finishedHandViews.count
        var finishedHandView: [PlayingCardView] = []
        var index: Int = 0
        while !currentPlayerViews.isEmpty {
            let cardView = currentPlayerViews.removeAtIndex(0)
            cardView.removeFromSuperview()
            let xoffset: CGFloat = CGFloat(14 * index)
            cardView.frame = CGRectMake(xoffset, 0, 40, 60)
            finishedHandContainerViews[finishedHandsCount].addSubview(cardView)
            finishedHandView.insert(cardView, atIndex: index)
            index++
        }
        finishedHandViews.append(finishedHandView)
        println(finishedHandViews)
        var cardView = splitHandViews.removeAtIndex(0)
        cardView.removeFromSuperview()
        cardView.frame = CGRectMake(0, 0, 90, 150)
        playerContainerView.addSubview(cardView)
        currentPlayerViews.insert(cardView, atIndex: 0)
        
        
        // Now that we have switched the hand, we should hit on the split hand
        currentPlayer.hit()
    }
    func bankrollUpdate() {
        // should KVO be used here???
        playerBankRollLabel.text = "\(currentPlayer.bankRoll)"
    }
    

    // MARK: - Dealer Observer
    func currentDealerHandUpdate(hand: BlackjackHand) {
        dealerScoreLabel.text = hand.valueDescription
    }

    func flipHoleCard() {
        dealerScoreLabel.hidden = false
        // hole card is always the dealer hand card at index 1
        let holeCard = theDealer.hand!.cards[1]
        let holeCardView = dealerCardViews[1]
        holeCardView.faceUp = true
    }
    func addCardToDealerHand(card: BlackjackCard) {
        println("added dealer card \(card)")
        var holeCard: Bool {
            return theDealer.hand!.cards.count == 2
        }
        displayDealerCard(card, faceup: !holeCard, index: theDealer.hand!.cards.count - 1)
    }
    
    func gameCompleted() {
        currentBet = 0.0
    }
}

