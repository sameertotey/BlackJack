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
    var previousBet: Double = 0.0
    var currentBet: Double = 0.0 {
        didSet {
            switch currentBet {
            case let x where x < gameConfiguration.minimumBet:
                statusLabel.text = "Minimum bet: \(gameConfiguration.minimumBet)"
                dealNewButton.hidden = true
            case let x where x > gameConfiguration.maximumBet:
                statusLabel.text = "Maximum bet: \(gameConfiguration.maximumBet)"
                currentBet = gameConfiguration.maximumBet
                dealNewButton.hidden = false
            case let x where x >= gameConfiguration.minimumBet:
                statusLabel.text = "Bet Ready"
                rebetButton.hidden = true
                dealNewButton.hidden = false
            default:
                println("Default")
            }
            currentBetButton.setTitle("\(currentBet)", forState: .Normal)
            currentBetButton.animate()
            let difference = currentBet - oldValue
            if difference > 0 {
                currentPlayer.bet(difference)
            }
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
        playerFinishedHandsVC = [playerFinishedHand1ViewController!, playerFinishedHand2ViewController!, playerFinishedHand3ViewController!]
        playerSplitHandsVC = [playerSplit1ViewController!, playerSplit2ViewController!, playerSplit3ViewController!]
        blackjackGame.play()
        setupButtons()
        currentBet = gameConfiguration.minimumBet
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCardProgress:", name: "cardShoeContentStatus", object: nil)
        
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func updateCardProgress(notification: NSNotification) {
        var progress: NSNumber = notification.object as NSNumber
        cardShoeProgressView.setProgress(progress.floatValue, animated: true)
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
    var playerHandContainerViewController: PlayerHandContainerViewController?
    var playerFinishedHand1ViewController: PlayerHandContainerViewController?
    var playerFinishedHand2ViewController: PlayerHandContainerViewController?
    var playerFinishedHand3ViewController: PlayerHandContainerViewController?
    var playerSplit1ViewController: PlayerHandContainerViewController?
    var playerSplit2ViewController: PlayerHandContainerViewController?
    var playerSplit3ViewController: PlayerHandContainerViewController?
    
    var playerFinishedHandsVC: [PlayerHandContainerViewController] = []
    var playerSplitHandsVC: [PlayerHandContainerViewController] = []
    
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
            case "Player Container":
                println("This is the player container...")
                playerHandContainerViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Finished Hand 1":
                println("This is the player finished 1 container...")
                playerFinishedHand1ViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Finished Hand 2":
                println("This is the player finished 2 container...")
                playerFinishedHand2ViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Finished Hand 3":
                println("This is the player finished 3 container...")
                playerFinishedHand3ViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Split Hand 1":
                println("This is the player Split 1 container...")
                playerSplit1ViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerSplit1ViewController?.cardWidthDivider = 1.0
                playerSplit1ViewController?.numberOfCardsPerWidth = 1.0
            case "Split Hand 2":
                println("This is the player Split 2 container...")
                playerSplit2ViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerSplit2ViewController?.cardWidthDivider = 1.0
                playerSplit2ViewController?.numberOfCardsPerWidth = 1.0
            case "Split Hand 3":
                println("This is the player Split 3 container...")
                playerSplit3ViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerSplit3ViewController?.cardWidthDivider = 1.0
                playerSplit3ViewController?.numberOfCardsPerWidth = 1.0
            default: break
            }
        }
    }
    
    // MARK: - Gesture Recognizers
    
    @IBOutlet weak var dealerContainerView: UIView!
    @IBOutlet weak var dealerHandView: UIView!
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var playerHandView: UIView!
    
    @IBOutlet var finishedHandContainerViews: [UIView]!
    var finishedHandViews: [[PlayingCardView]] = []
    
    @IBOutlet var splitHandContainerViews: [UIView]!
    var splitHandViews: [PlayingCardView] = []       // There is only one card per split hand view
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playerBankRollLabel: UILabel!
    
    
    @IBOutlet weak var doubleDownButton: GameActionButton!
    @IBOutlet weak var splitHandButton: GameActionButton!
    @IBOutlet weak var surrenderButton: GameActionButton!
    @IBOutlet weak var buyInsuranceButton: GameActionButton!
    @IBOutlet weak var declineInsuranceButton: GameActionButton!
    @IBOutlet weak var hitButton: GameActionButton!
    @IBOutlet weak var standButton: GameActionButton!
    
    @IBOutlet weak var currentBetButton: GameActionButton!
    
    @IBOutlet weak var chip100Button: GameActionButton!
    @IBOutlet weak var chip25Button: GameActionButton!
    @IBOutlet weak var chip5Button: GameActionButton!
    @IBOutlet weak var chip1Button: GameActionButton!
    @IBOutlet weak var rebetButton: GameActionButton!
    @IBOutlet weak var dealNewButton: GameActionButton!
    
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var buttonContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerheightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dealerHandViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dealerHandViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playerHandViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerHandViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var finishedHandsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var finishedHandsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var splitHandsViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var splitHandsViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cardShoeContainerView: UIView!
    @IBOutlet weak var cardShoeProgressView: UIProgressView!
    
    // Actions

    func setupSubViews() {
//        playerContainerView.clipsToBounds = true
//        dealerContainerView.clipsToBounds = true
    }
    
    func setupButtons () {
        
        hideAllPlayerButtons()
        switch blackjackGame.gameState {
        case .Deal:
            setupButtonsForDeal()
        case .Players:
            setupButtonsForPlay()
        default:
            println("This should not happen, you should be in only Deal or Player state")
        }
    }
    
    let position0 = CGPointMake(0, 0)
    

    let positions = [CGPointMake(30.0, 70.0), CGPointMake(100.0, 70.0), CGPointMake(170.0, 70.0), CGPointMake(30.0, 20.0), CGPointMake(100.0, 20.0), CGPointMake(170.0, 20.0)]

    
    func setupButtonsForDeal() {
        var buttons: [GameActionButton] = []
        buttons.append(chip1Button)
        buttons.append(chip5Button)
        buttons.append(dealNewButton)
        buttons.append(chip25Button)
        buttons.append(chip100Button)
        buttons.append(rebetButton)

        setButtonsAndMessage(buttons, message: "Play Blackjack")
        bankrollUpdate()
        
        if previousBet == 0.0 {
            rebetButton.hidden = true
        }
        
    }
    
    func setButtonsAndMessage(buttons: [GameActionButton], message: String?) {
        for index in 0..<buttons.count {
            buttons[index].hidden = false
            buttons[index].center = position0
        }
        
        UIView.animateWithDuration(0.55, delay: 0, options: .CurveEaseOut, animations: {
            for index in 0..<buttons.count {
                buttons[index].center = self.positions[index]
            }
            }) { _ in
                if message != nil {
                    self.statusLabel.text = message
                }
        }
    }
    
    func setupButtonsForPlay() {
        var buttons: [GameActionButton] = []
        buttons.append(hitButton)
        buttons.append(standButton)
        if let currentPlayerHand = currentPlayer.currentHand {
            if currentPlayerHand.cards.count == 2 {
                buttons.append(doubleDownButton)
                if currentPlayerHand.initialCardPair {
                    if currentPlayer.hands.count < gameConfiguration.maxHandsWithSplits {
                        buttons.append(splitHandButton)
                    }
                }
            }
        }
        
        if currentPlayer.insuranceAvailable {
            buttons.append(buyInsuranceButton)
            buttons.append(declineInsuranceButton)
        } else {
            if currentPlayer.surrenderOptionAvailabe {
                buttons.append(surrenderButton)
            }
        }
        var message: String?
        switch currentPlayer.previousAction {
        case .BuyInsurance:
            message = "Insurance complete"
        case .DeclineInsurance:
            message = "Insurance declined"
        case .Bet:
            message = "Make a move"
        case .Hit:
            message = "Hit last hand"
        case .Stand:
            message = "Stood last hand"
        case .Surrender:
            message = "Surrendered last hand"
        case .DoubleDown:
            message = "Double Down last hand"
        default:
            message = nil
        }
        setButtonsAndMessage(buttons, message: message)
    }
    
    func hideAllPlayerButtons() {
        for subView in buttonContainerView.subviews {
            if subView is GameActionButton {
                (subView as GameActionButton).hidden = true
            }
        }
    }
    
    
    @IBAction func playerActionButtonTouchUpInside(sender: GameActionButton) {
        switch sender {
        case chip1Button:
            currentBet += 1
        case chip5Button:
            currentBet += 5
        case chip25Button:
            currentBet += 25
        case chip100Button:
            currentBet += 100
        case currentBetButton:
            currentPlayer.bankRoll += currentBet
            currentBet = 0
            bankrollUpdate()
        case dealNewButton:
            deal()
        case rebetButton:
            currentBet = previousBet
            deal()
        default:
            println("received touch from unknown sender: \(sender)")
        }
    
    }
    
    func deal() {
        if blackjackGame.gameState == .Deal {
            currentPlayer.currentBet = currentBet
            previousBet = currentBet
            currentBetButton.enabled = false
            resetCardViews()
            blackjackGame.deal()
            blackjackGame.update()
            setupButtons()
        }
    }
    
    
    func resetCardViews() {
        finishedHandViews.removeAll(keepCapacity: true)
        splitHandViews.removeAll(keepCapacity: true)
        dealerHandContainerViewController?.reset()
        playerHandContainerViewController?.reset()
        for index in 0..<3 {
            playerSplitHandsVC[index].reset()
            playerFinishedHandsVC[index].reset()
        }
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
    
    // MARK: - Card Player Observer
    
    func currentHandStatusUpdate(hand: BlackjackHand) {
 
        playerHandContainerViewController?.setPlayerScoreText(hand.valueDescription)
    }
    
    func addCardToCurrentHand(card: BlackjackCard)  {
        playerHandContainerViewController?.addCardToPlayerHand(card)
        playerHandContainerViewController?.playerHandIndex = currentPlayer.currentHandIndex
    }
    
    func addnewlySplitHand(card: BlackjackCard) {
        if let cardView = playerHandContainerViewController?.removeLastCard() {
            let splitHandsCount = splitHandViews.count
            playerSplitHandsVC[splitHandsCount].addCardToPlayerHand(card)
            splitHandViews.insert(cardView, atIndex: splitHandsCount)
        }
    }
    
    func switchHands() {
        println("Advance to next hand....")
        let finishedHandsCount = finishedHandViews.count
        var finishedHandView: [PlayingCardView] = []
        let savedPlayerText = playerHandContainerViewController?.getPlayerScoreText()
        if let cardView = playerHandContainerViewController?.removeFirstCard() {
            var removedCardView: PlayingCardView? = cardView
            playerFinishedHandsVC[finishedHandsCount].playerHandIndex = playerHandContainerViewController!.playerHandIndex
            if let scoreText = savedPlayerText {
                playerFinishedHandsVC[finishedHandsCount].setPlayerScoreText(scoreText)
            }
            do {
                playerFinishedHandsVC[finishedHandsCount].addCardToPlayerHand(removedCardView!.card)
                finishedHandView.append(removedCardView!)
                removedCardView = playerHandContainerViewController?.removeLastCard()
            } while removedCardView != nil
        }
        finishedHandViews.append(finishedHandView)
        // find the next split hand card....
        for splitVCIndex in 0..<3 {
            if let cardView = playerSplitHandsVC[splitVCIndex].removeLastCard() {
                addCardToCurrentHand(cardView.card)
                break
            }
        }
        
        // Now that we have switched the hand, we should hit on the split hand
        currentPlayer.hit()
    }
    func bankrollUpdate() {
        // should KVO be used here???
        playerBankRollLabel.text = "\(currentPlayer.bankRoll)"
        println("Bankroll is now \(currentPlayer.bankRoll) ")
    }
    

    // MARK: - Blackjack Game Delegate
    
    func gameCompleted() {
        currentBet = 0
        if gameConfiguration.autoWagerPreviousBet {
            currentBet = previousBet
        }
        statusLabel.text = "Game Over!"
        currentBetButton.enabled = true
    
        playerHandContainerViewController!.displayResult(currentPlayer.hands[playerHandContainerViewController!.playerHandIndex!].handState)
        for finishedHandsIndex in 0..<3 {
            if let handIndex = playerFinishedHandsVC[finishedHandsIndex].playerHandIndex {
                playerFinishedHandsVC[finishedHandsIndex].displayResult(currentPlayer.hands[handIndex].handState)
            }
        }
    }
}

