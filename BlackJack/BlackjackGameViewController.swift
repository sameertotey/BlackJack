//
//  BlackjackGameViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class BlackjackGameViewController: UIViewController, CardPlayerObserver, BlackjackGameDelegate {
    
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()
    
    var blackjackGame: BlackjackGame!
    var currentPlayer: Player!
    var gameConfiguration: GameConfiguration!
    var theDealer: Dealer!
    var currentBet: Double = 0.0 {
        didSet {
            currenBetLabel.text = "\(currentBet)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        blackjackGame = BlackjackGame()
        blackjackGame.blackjackGameDelegate = self
        currentPlayer = Player(name: "Sameer")
        currentPlayer.observer = self
        currentPlayer.bankRoll = 100.00
        currentPlayer.delegate = blackjackGame
        playerBankRollLabel.text = "\(currentPlayer.bankRoll)"
        theDealer = Dealer()
        setGameConfiguration()
        theDealer.cardSource = blackjackGame
        theDealer.observer = dealerHandContainerViewController
        blackjackGame.dealer = theDealer
        
        setupSubViews()
        setupButtons()
        blackjackGame.play()
    }

    func setGameConfiguration() {
        gameConfiguration = GameConfiguration()
        blackjackGame.gameConfiguration = gameConfiguration
        theDealer.gameConfiguration = gameConfiguration
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
        if let identifier = segue.identifier {
            switch identifier {
            case "SaveFromConfiguration":
                setGameConfiguration()
                fallthrough
            case "CancelFromConfiguration":
                dismissViewControllerAnimated(true, completion: nil)
            default: break
            }
        }
    }

    var dealerHandContainerViewController: DealerHandContainerViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Present Game Configuration":
                if segue.destinationViewController is UINavigationController {
                    let toVC = segue.destinationViewController as UINavigationController
                    toVC.modalPresentationStyle = .Custom
                    toVC.transitioningDelegate = self.modalTransitioningDelegate
                }
            case "Dealer Container":
                println("This is a dealer container...")
                dealerHandContainerViewController = segue.destinationViewController as? DealerHandContainerViewController
            default: break
            }
        }
    }
    
    // MARK: - Gesture Recognizers
    
    @IBOutlet weak var dealerContainerView: UIView!
    var dealerCardViews: [PlayingCardView] = []
    @IBOutlet weak var dealerHandView: UIView!
    
    @IBOutlet weak var playerContainerView: UIView!
    var currentPlayerViews: [PlayingCardView] = []
    @IBOutlet weak var playerHandView: UIView!
    
    @IBOutlet var finishedHandContainerViews: [UIView]!
    var finishedHandViews: [[PlayingCardView]] = []
    
    @IBOutlet var splitHandContainerViews: [UIView]!
    var splitHandViews: [PlayingCardView] = []       // There is only one card per split hand view
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var currenBetLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playerBankRollLabel: UILabel!
    
    @IBOutlet weak var playerButtonContainerView: UIView!
    
    @IBOutlet weak var doubleDownButton: GameActionButton!
    @IBOutlet weak var splitHandButton: GameActionButton!
    @IBOutlet weak var surrenderButton: UIButton!
    @IBOutlet weak var buyInsuranceButton: UIButton!
    @IBOutlet weak var declineInsuranceButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var hitButton: GameActionButton!
    @IBOutlet weak var standButton: GameActionButton!
    
    @IBOutlet weak var dealerHandViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dealerHandViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playerHandViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerHandViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var finishedHandsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var finishedHandsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var splitHandsViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var splitHandsViewWidthConstraint: NSLayoutConstraint!
    
    // Actions

    func setupSubViews() {
        playerContainerView.clipsToBounds = true
        dealerContainerView.clipsToBounds = true
        
    }
    
    func setupButtons() {
        if currentBet < gameConfiguration.minimumBet {
            self.statusLabel.text = "Minimum bet: \(self.gameConfiguration.minimumBet)"
            self.doubleDownButton.hidden = true
            self.splitHandButton.hidden = true
            self.surrenderButton.hidden = true
            self.buyInsuranceButton.hidden = true
            self.declineInsuranceButton.hidden = true
            self.betButton.hidden = true
            self.dealButton.hidden = true
            self.hitButton.hidden = true
            self.standButton.hidden = true

            UIView.transitionWithView(betButton, duration: 0.25, options: .CurveEaseOut | .TransitionFlipFromBottom, animations: {
                self.betButton.hidden = false
                 }, completion: { status in
                    println("Done")
                })
        } else {
            switch currentPlayer.previousAction! {
            case .Wager:
                enableNewGameButtons()
            case .Bet:
                statusLabel.text = "Play!"
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }
            case .Hit:
                statusLabel.text = ""
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }
            case .Stand:
                statusLabel.text = ""
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }
            case .Split:
                statusLabel.text = ""
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }
            case .DoubleDown:
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }
            case .Surrender:
                statusLabel.text = ""
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }

            case .BuyInsurance:
                statusLabel.text = ""
                if blackjackGame.gameState == .Players {
                    enablePlayButtons()
                } else {
                    enableNewGameButtons()
                }
            }
        }
        
    }
    
    func enablePlayButtons() {
        statusLabel.text = ""
            UIView.transitionWithView(playerButtonContainerView, duration: 0.55, options: .CurveEaseOut | .TransitionFlipFromBottom, animations: {
            self.playerScoreLabel.text = self.currentPlayer.currentHand?.valueDescription
            self.doubleDownButton.hidden = !(self.currentPlayer.currentHand?.cards.count == 2) ?? true
            self.splitHandButton.hidden = !(self.currentPlayer.currentHand?.initialCardPair == true) ?? true
            self.surrenderButton.hidden = !self.currentPlayer.surrenderOptionAvailabe
            self.buyInsuranceButton.hidden = !self.currentPlayer.insuranceAvailable
            if self.gameConfiguration.surrenderAllowed {
                self.declineInsuranceButton.hidden = !self.currentPlayer.insuranceAvailable}
            self.betButton.hidden = true
            self.dealButton.hidden = true
            self.hitButton.hidden = false
            self.standButton.hidden = false
            }, completion: {  status in
//                self.playerScoreLabel.text = self.currentPlayer.currentHand?.valueDescription
//                self.doubleDownButton.hidden = !(self.currentPlayer.currentHand?.cards.count == 2) ?? true
//                self.splitHandButton.hidden = !(self.currentPlayer.currentHand?.initialCardPair == true) ?? true
//                self.surrenderButton.hidden = !self.currentPlayer.surrenderOptionAvailabe
//                self.buyInsuranceButton.hidden = !self.currentPlayer.insuranceAvailable
//                if self.gameConfiguration.surrenderAllowed {
//                    self.declineInsuranceButton.hidden = !self.currentPlayer.insuranceAvailable}
//                self.betButton.hidden = true
//                self.dealButton.hidden = true
//                self.hitButton.hidden = false
//                self.standButton.hidden = false
                println("Done2")
})
     }
    
    func enableNewGameButtons() {
        self.statusLabel.text = "Ready to Deal"
        self.doubleDownButton.hidden = true
        self.splitHandButton.hidden = true
        self.surrenderButton.hidden = true
        self.buyInsuranceButton.hidden = true
        self.declineInsuranceButton.hidden = true
        self.betButton.hidden = true
        self.dealButton.hidden = true
        self.hitButton.hidden = true
        self.standButton.hidden = true

        UIView.transitionWithView(dealButton, duration: 0.55, options: .CurveEaseOut | .TransitionFlipFromBottom, animations: {
            self.dealButton.hidden = false
            }, completion: {status in
                println("Done3")
        })
    }
    
    @IBAction func dealButtonTouchUpInside(sender: UIButton) {
        if blackjackGame.gameState == .Deal {
            resetCardViews()
            blackjackGame.deal()
            blackjackGame.update()
            setupButtons()
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
        //            doubleDownButton.hidden = true
        for viewContainer in finishedHandContainerViews {
            for view in viewContainer.subviews {
                if view is PlayingCardView {
                    view.removeFromSuperview()
                }
            }
        }
        finishedHandViews.removeAll(keepCapacity: true)
        
        dealerHandContainerViewController?.reset()
    }
    
    func displayPlayerCard(card: BlackjackCard, index: Int) {
        println("player index \(index)")
        let cardWidth = CGFloat(playerHandViewWidthConstraint.constant / 2.0)
        let xOffset = cardWidth * CGFloat(index) / 3.0
        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, playerHandViewHeightConstraint.constant))
        playingCardView.faceUp = true
        playingCardView.card = card
        playerContainerView.addSubview(playingCardView)
        currentPlayerViews.insert(playingCardView, atIndex: index)
    }
    
    func displayDealerCard(card: BlackjackCard, faceup: Bool, index: Int) {
//        println("dealer index \(index)")
//        let cardWidth = CGFloat(dealerHandViewWidthConstraint.constant / 2.0)
//        let xOffset = cardWidth * CGFloat(index) / 3.0
//        let playingCardView = PlayingCardView(frame: CGRectMake(xOffset, 0, cardWidth, dealerHandViewHeightConstraint.constant))
//        playingCardView.faceUp = faceup
//        playingCardView.card = card
//        dealerContainerView.addSubview(playingCardView)
//        dealerCardViews.insert(playingCardView, atIndex: index)
    }
    
    @IBAction func hitButtonTouchUpInside(sender: UIButton) {
        currentPlayer.hit()
        setupButtons()
    }
    
    @IBAction func standButtonTouchUpInside(sender: UIButton) {
        currentPlayer.stand()
        setupButtons()
    }
    
    @IBAction func doubleButtonTouchUpInside(sender: UIButton) {
        currentPlayer.doubleDown()
        setupButtons()
    }

    @IBAction func splitHandButtonTouchUpInside(sender: UIButton) {
        currentPlayer.split()
        setupButtons()
    }
    
    @IBAction func surrenderButtonTouchUpInside(sender: UIButton) {
        currentPlayer.surrenderHand()
        setupButtons()
    }
    
    @IBAction func buyInsuranceButtonTouchUpInside(sender: UIButton) {
        currentPlayer.buyInsurance()
        setupButtons()
    }
    
    @IBAction func declineInsuranceButtonTouchUpInside(sender: UIButton) {
        currentPlayer.declineInsurance()
        setupButtons()
    }
    
    @IBAction func betButtonTouchUpInside(sender: UIButton) {
        // add logic to alter bets lated
        currentBet = gameConfiguration.minimumBet
        currentPlayer.bet(currentBet)
        setupButtons()
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
        cardView.frame = CGRectMake(0, 0, splitHandsViewWidthConstraint.constant / 3.0, splitHandsViewHeightContraint.constant)
        let splitHandsCount = splitHandViews.count
        splitHandContainerViews[splitHandsCount].addSubview(cardView)
        splitHandViews.insert(cardView, atIndex: splitHandsCount)
    }
    
    func switchHands() {
        println("Advance to next hand....")
        let finishedHandsCount = finishedHandViews.count
        var finishedHandView: [PlayingCardView] = []
        var cardIndex: Int = 0
        while !currentPlayerViews.isEmpty {
            let cardView = currentPlayerViews.removeAtIndex(0)
            cardView.removeFromSuperview()
            let xoffset: CGFloat = finishedHandsViewWidthConstraint.constant / 18.0 * CGFloat(cardIndex)
            cardView.frame = CGRectMake(xoffset, 0, finishedHandsViewWidthConstraint.constant / 6.0, finishedHandsViewHeightConstraint.constant)
            finishedHandContainerViews[finishedHandsCount].addSubview(cardView)
            finishedHandView.insert(cardView, atIndex: cardIndex)
            cardIndex++
        }
        finishedHandViews.append(finishedHandView)
        println(finishedHandViews)
        var cardView = splitHandViews.removeAtIndex(0)
        cardView.removeFromSuperview()
        addCardToCurrentHand(cardView.card)
        
        // Now that we have switched the hand, we should hit on the split hand
        currentPlayer.hit()
    }
    func bankrollUpdate() {
        // should KVO be used here???
        playerBankRollLabel.text = "\(currentPlayer.bankRoll)"
    }
    

    // MARK: - Blackjack Game Delegate
    
    func gameCompleted() {
        currentBet = 0.0
        statusLabel.text = "Game Over!"
    }
}

