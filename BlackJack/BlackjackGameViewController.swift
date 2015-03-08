//
//  BlackjackGameViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

private var MyObservationContext = 0



class BlackjackGameViewController: UIViewController, CardPlayerObserver, UIDynamicAnimatorDelegate {
    
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()
    
    var blackjackGame: BlackjackGame!
    var currentPlayer: Player!
    var gameConfiguration: GameConfiguration!
    var audioController: AudioController!
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
                statusLabel.text = "Ready to Deal"
//                rebetButton.hidden = true
                dealNewButton.hidden = false
            default:
                println("Default")
            }
            currentBetButton.setTitle("\(currentBet)", forState: .Normal)
            currentBetButton.animate()
            let difference = currentBet - oldValue
            if difference > 0 {
                if !currentPlayer.bet(difference) {
                    statusLabel.text = "Not enough bankroll"
                    currentBet = oldValue
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        blackjackGame = BlackjackGame()
        currentPlayer = Player(name: "Sameer")
        currentPlayer.observer = self
        currentPlayer.bankRoll = 100.00
        currentPlayer.delegate = blackjackGame
        playerBankRollButton.setTitle("\(currentPlayer.bankRoll)", forState: .Normal)
        theDealer = Dealer()
        setGameConfiguration()
        theDealer.cardSource = blackjackGame
        theDealer.observer = dealerHandContainerViewController
        blackjackGame.dealer = theDealer
        
        playerFinishedHandsVC = [playerFinishedHand1ViewController!, playerFinishedHand2ViewController!, playerFinishedHand3ViewController!]
        playerSplitHandsVC = [playerSplit1ViewController!, playerSplit2ViewController!, playerSplit3ViewController!]
        blackjackGame.play()
        hideAllPlayerButtons()
        audioController = AudioController()
        currentBet = gameConfiguration.minimumBet
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCardProgress:", name: NotificationMessages.cardShoeContentStatus, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameCompleted", name: NotificationMessages.dealerHandOver, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setStatusMessage:", name: NotificationMessages.setStatus, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setPlayerReady", name: NotificationMessages.playerLabelDisplayed, object: nil)
        startObservingBankroll(currentPlayer)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        stopObservingBankroll(currentPlayer)
    }
    func updateCardProgress(notification: NSNotification) {
        var progress: NSNumber = notification.object as NSNumber
        cardShoeProgressView.setProgress(progress.floatValue, animated: true)
    }
    func setStatusMessage(notification: NSNotification) {
        var message: String = notification.object as String
        zoomStatusLabel(message)
    }
    
    func setGameConfiguration() {
        gameConfiguration = GameConfiguration()
        blackjackGame.gameConfiguration = gameConfiguration
        theDealer.gameConfiguration = gameConfiguration
        currentPlayer.gameConfiguration = gameConfiguration
        AudioController.GameSounds.soundEffectsEnabled = gameConfiguration.enableSoundEffects
        playingCardShoeView.numDecks = gameConfiguration.numDecks
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
                dealerHandContainerViewController = segue.destinationViewController as? DealerHandContainerViewController
                dealerHandContainerViewController!.cardShoeContainer = cardShoeContainerView
            case "Player Container":
                playerHandContainerViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerHandContainerViewController!.cardShoeContainer = cardShoeContainerView
            case "Finished Hand 1":
                playerFinishedHand1ViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Finished Hand 2":
                playerFinishedHand2ViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Finished Hand 3":
                playerFinishedHand3ViewController = segue.destinationViewController as? PlayerHandContainerViewController
            case "Split Hand 1":
                playerSplit1ViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerSplit1ViewController?.cardWidthDivider = 1.0
                playerSplit1ViewController?.numberOfCardsPerWidth = 1.0
            case "Split Hand 2":
                playerSplit2ViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerSplit2ViewController?.cardWidthDivider = 1.0
                playerSplit2ViewController?.numberOfCardsPerWidth = 1.0
            case "Split Hand 3":
                playerSplit3ViewController = segue.destinationViewController as? PlayerHandContainerViewController
                playerSplit3ViewController?.cardWidthDivider = 1.0
                playerSplit3ViewController?.numberOfCardsPerWidth = 1.0
            default: break
            }
        }
    }
    
    // MARK: - Gesture Recognizers
    
    @IBOutlet weak var dealerContainerView: UIView!
    @IBOutlet weak var dealerContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dealerHandView: UIView!
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var playerContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playerHandView: UIView!
    
    @IBOutlet var finishedHandContainerViews: [UIView]!
    var finishedHandViewCards: [[BlackjackCard]] = []
    
    @IBOutlet var splitHandContainerViews: [UIView]!
    var splitHandViewCards: [BlackjackCard] = []       // There is only one card per split hand view
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var playerBankRollButton: GameActionButton!
    @IBOutlet weak var playerBankRollButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerBankRollButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var doubleDownButton: GameActionButton!
    @IBOutlet weak var splitHandButton: GameActionButton!
    @IBOutlet weak var surrenderButton: GameActionButton!
    @IBOutlet weak var buyInsuranceButton: GameActionButton!
    @IBOutlet weak var declineInsuranceButton: GameActionButton!
    @IBOutlet weak var hitButton: GameActionButton!
    @IBOutlet weak var standButton: GameActionButton!
    
    @IBOutlet weak var currentBetButton: GameActionButton!
    @IBOutlet weak var currentBetButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentBetButtonHeightConstraint: NSLayoutConstraint!
    
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
    
    private var animator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var pushBehavior: UIPushBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
    
    @IBOutlet weak var playingCardShoeView: PlayingCardShoeView!
    
    // Actions

    override func viewWillAppear(animated: Bool) {
        println("The size is view appearing \(view.bounds.size)")
        setupSubViews(view.bounds.size)
    }
    
    func setupSubViews(size: CGSize) {
        hideAllPlayerButtons()
        setupButtons()
        if size.width == 320.0 {
            playerBankRollButtonHeightConstraint.constant = 50.0
            playerBankRollButtonWidthConstraint.constant = 50.0
        }

    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        println("new traits: \(newCollection) ")
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        println("The new size is \(size)")
        setupSubViews(size)
    }
    
    func setupButtons () {
        switch blackjackGame.gameState {
        case .Deal:
            setupButtonsForDeal()
        case .Players:
            setupButtonsForPlay()
        default:
            println("This should not happen, you should be in only Deal or Player state")
        }
        self.view.window?.rootViewController?.view?.userInteractionEnabled = true
      }
    
    let position0 = CGPointMake(-30, -30)
    

    let positions = [CGPointMake(30.0, 70.0), CGPointMake(100.0, 70.0), CGPointMake(170.0, 70.0), CGPointMake(30.0, 20.0), CGPointMake(100.0, 20.0), CGPointMake(170.0, 20.0)]

    
    func setupButtonsForDeal() {
        var buttons: [GameActionButton] = []
        buttons.append(chip1Button)
        buttons.append(chip5Button)
        buttons.append(dealNewButton)
        buttons.append(chip25Button)
        buttons.append(chip100Button)
        buttons.append(rebetButton)

        setButtonsAndMessage(buttons, message: nil)
        bankrollUpdate()
        
        if previousBet == 0.0 {
            rebetButton.hidden = true
        }
        
    }
    
    func setButtonsAndMessage(buttons: [GameActionButton], message: String?) {
        for button in buttons {
            button.hidden = false
            button.center = position0
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
            for (index, button) in enumerate(buttons) {
                button.center = self.positions[index]
                
            }
            }) { _ in
                // This is needed in order to make them work correctly when a change in orientation occurs
                // for some reason the animated values are overwritten... Adding constaints would have worked here
                for (index, button) in enumerate(buttons) {
                    if button.center != self.positions[index] {
                        button.center = self.positions[index]
                    }
                }
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
                if gameConfiguration.doublingDownAllowed {
                    if gameConfiguration.doublingDownAllowedOn10and11Only {
                        if currentPlayerHand.value >= 10 && currentPlayerHand.value <= 11 {
                            buttons.append(doubleDownButton)
                        }
                    } else if gameConfiguration.doublingDownAllowedOn9and10and11Only {
                        if currentPlayerHand.value >= 9 && currentPlayerHand.value <= 11 {                                buttons.append(doubleDownButton)
                            }
                    } else {
                        buttons.append(doubleDownButton)
                    }
                }
                
                if gameConfiguration.splitsAllowed {
                    if currentPlayerHand.initialCardPair {
                        if currentPlayerHand.cards.first!.rank == .Ace {
                            if gameConfiguration.canSplitAces {
                                if currentPlayer.hands.count < gameConfiguration.maxHandsWithSplits {
                                    buttons.append(splitHandButton)
                                }
                            }
                        } else if currentPlayer.hands.count < gameConfiguration.maxHandsWithSplits {
                            buttons.append(splitHandButton)
                        }
                    } else if gameConfiguration.canSplitAny10Cards {
                        if (currentPlayerHand.cards[0].rank.values.first == 10) && (currentPlayerHand.cards[1].rank.values.first == 10) {
                            if currentPlayer.hands.count < gameConfiguration.maxHandsWithSplits {
                                buttons.append(splitHandButton)
                            }
                        }
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
        setButtonsAndMessage(buttons, message: nil)
    }
    
    func hideAllPlayerButtons() {
        self.view.window?.rootViewController?.view?.userInteractionEnabled = false
        for subView in buttonContainerView.subviews {
            if subView is GameActionButton {
                (subView as GameActionButton).hidden = true
            }
        }
    }
    
    
    @IBAction func playerActionButtonTouchUpInside(sender: GameActionButton) {
        if readyForNextAction() {
            switch sender {
            case chip1Button:
                animateChip(sender.imageForState(.Normal), amount: 1.0)
            case chip5Button:
                animateChip(sender.imageForState(.Normal), amount: 5.0)
            case chip25Button:
                animateChip(sender.imageForState(.Normal), amount: 25.0)
            case chip100Button:
                animateChip(sender.imageForState(.Normal), amount: 100.0)
            case currentBetButton:
                currentPlayer.bankRoll += currentBet
                currentBet = 0
            case dealNewButton:
                deal()
            case rebetButton:
                currentBet = previousBet
                deal()
            default:
                println("received touch from unknown sender: \(sender)")
            }
        }
    }
    
    func animateChip(chipImage: UIImage?, amount: Double) {
        let chipImageView = UIImageView(image: chipImage)
        chipImageView.frame = CGRectMake(0, 0, 1.0, 1.0)
        let finalSize = CGRectMake(0, 0, 40.0, 40.0)
        chipImageView.layer.cornerRadius = 20.0
        chipImageView.clipsToBounds = true
        chipImageView.center = playerBankRollButton.center
        playerContainerView.addSubview(chipImageView)
        chipImageView.alpha = 0.1
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            chipImageView.frame.size = finalSize.size
            chipImageView.center = self.playerBankRollButton.center
            chipImageView.alpha = 1.0
            self.currentBetButton.alpha = 0.1
            }) { _ in
                self.chipDynamicBehaviors(chipImageView, amount: amount)
                AudioController.play(.Coin)
        }
    }
    
    private func chipDynamicBehaviors(chipView: UIImageView, amount: Double) {
        if animator == nil {
            animator = UIDynamicAnimator(referenceView: playerContainerView)
            animator!.delegate = self
        }
        pushBehavior = UIPushBehavior(items: [chipView], mode: .Instantaneous)
        pushBehavior!.pushDirection = CGVectorMake(0.6, 0.4)
        pushBehavior!.magnitude = 1
        animator!.addBehavior(pushBehavior)
        
        snapBehavior = UISnapBehavior(item: chipView, snapToPoint: currentBetButton.center)
        snapBehavior!.damping = 0.5
        animator!.addBehavior(snapBehavior)
        dynamicChipViews.append(chipView)
        currentBet += amount
    }
    
    private var dynamicChipViews: [UIImageView] = []
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
        
        UIView.transitionWithView(currentBetButton, duration: 0.2, options: .CurveEaseOut | .TransitionFlipFromLeft, animations: {
            for aChipView in self.dynamicChipViews {
                self.currentBetButton.alpha = 1.0
                aChipView.removeFromSuperview()
            }
            }, completion: { _ in
        })
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
    }

    var predealTotal = 0.0
    func deal() {
        hideAllPlayerButtons()
        if blackjackGame.gameState == .Deal {
            if currentBet >= gameConfiguration.minimumBet {
                currentPlayer.currentBet = currentBet
                previousBet = currentBet
                currentBetButton.enabled = false
                resetCardViews()
                predealTotal = currentPlayer.currentBet + currentPlayer.bankRoll
                blackjackGame.deal()
                blackjackGame.update()
                //            setupButtons()
            } else {
                statusLabel.text = "Need to obtain more points thru game configuration"
            }
        }
    }
    
    
    func resetCardViews() {
        finishedHandViewCards.removeAll(keepCapacity: true)
        splitHandViewCards.removeAll(keepCapacity: true)
        dealerHandContainerViewController?.reset()
        playerHandContainerViewController?.reset()
        for index in 0..<3 {
            playerSplitHandsVC[index].reset()
            playerFinishedHandsVC[index].reset()
        }
    }
      
    @IBAction func hitButtonTouchUpInside(sender: UIButton) {
        performHit()
     }
    
    func performHit() {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.hit()
//            setupButtons()
        }
    }
   
    @IBAction func standButtonTouchUpInside(sender: UIButton) {
        performStand()
     }
    
    func performStand() {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.stand()
//            setupButtons()
        }
    }
    
    @IBAction func doubleButtonTouchUpInside(sender: UIButton) {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.doubleDown()
//            setupButtons()
        }
     }

    @IBAction func splitHandButtonTouchUpInside(sender: UIButton) {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.split()
//            setupButtons()
        }
    }
    
    @IBAction func surrenderButtonTouchUpInside(sender: UIButton) {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.surrenderHand()
//            setupButtons()
        }
    }
    
    @IBAction func buyInsuranceButtonTouchUpInside(sender: UIButton) {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.buyInsurance()
//            setupButtons()
        }
    }
    
    @IBAction func declineInsuranceButtonTouchUpInside(sender: UIButton) {
        if readyForNextAction() {
            hideAllPlayerButtons()
            currentPlayer.declineInsurance()
//            setupButtons()
        }
    }
    
    // MARK: - Card Player Observer
    
    func currentHandStatusUpdate(hand: BlackjackHand) {
        playerHandContainerViewController?.setPlayerScoreText(hand.valueDescription)
    }
    
    func addCardToCurrentHand(card: BlackjackCard)  {
        playerHandContainerViewController?.playerHandIndex = currentPlayer.currentHandIndex
        playerHandContainerViewController?.addCardToPlayerHand(card)
    }
    
    func addnewlySplitHand(card: BlackjackCard) {
        if let cardViewCard = playerHandContainerViewController?.removeLastCard(true) {
            let splitHandsCount = splitHandViewCards.count
            playerSplitHandsVC[splitHandsCount].addCardToPlayerHand(card)
            splitHandViewCards.insert(cardViewCard, atIndex: splitHandsCount)
        }
    }
    
    func switchHands() {
        println("Advance to next hand....")
        let finishedHandsCount = finishedHandViewCards.count    // This is an array of array of cards, two dimentional array
        var finishedHandViewCardsItem: [BlackjackCard] = []
        let savedPlayerText = playerHandContainerViewController?.getPlayerScoreText()
        
        if let cardViewCard = playerHandContainerViewController?.removeFirstCard() {
            var removedCardViewCard: BlackjackCard? = cardViewCard
            playerFinishedHandsVC[finishedHandsCount].playerHandIndex = playerHandContainerViewController!.playerHandIndex
            if let scoreText = savedPlayerText {
                playerFinishedHandsVC[finishedHandsCount].setPlayerScoreText(scoreText)
            }
            do {
                playerFinishedHandsVC[finishedHandsCount].addCardToPlayerHand(removedCardViewCard!)
                finishedHandViewCardsItem.append(removedCardViewCard!)
                removedCardViewCard = playerHandContainerViewController?.removeFirstCard()
            } while removedCardViewCard != nil
        }
        finishedHandViewCards.append(finishedHandViewCardsItem)
        playerHandContainerViewController?.reset()

        // find the next split hand card....
        for splitVCIndex in 0..<3 {
            if let cardViewCard = playerSplitHandsVC[splitVCIndex].removeLastCard(true) {
                println("Advanced to next hand in between....")
                addCardToCurrentHand(cardViewCard)
                break
            }
        }
        
        // Now that we have switched the hand, we should hit on the split hand
        println("Advanced to next hand complete..Auto Hit..")

        currentPlayer.hit()
    }
    
    func bankrollUpdate() {
        // should KVO be used here???
        playerBankRollButton.setTitle("\(currentPlayer.bankRoll)", forState: .Normal)
        playerBankRollButton.animate()
        println("Bankroll is now \(currentPlayer.bankRoll) ")
    }
    

    func setPlayerReady() {
        println("Inside set player ready---")
        if blackjackGame.gameState == .Players {
            setupButtons()
        }
    }
    // MARK: - Blackjack Game Delegate
    func gameCompleted() {
        let savedText = statusLabel.text
        let differenceInBalance = predealTotal - currentPlayer.bankRoll
        currentBet = 0
        if gameConfiguration.autoWagerPreviousBet {
            currentBet = previousBet
        }

        var gameSound: AudioController.GameSound

        switch differenceInBalance {
        case let x where x > 0:
            statusLabel.text = "Game Over - Lost \(x)"
            gameSound = .Lost
            println("Lost \(x)")
        case let x where x < 0:
            statusLabel.text = "Game Over - Won \(-x)"
            gameSound = .Won
            println("Won \(-x)")

        default:
            statusLabel.text = "Game Over - Push!"
            gameSound = .Tied
            println("Push")

        }
        currentBetButton.enabled = true
        
        playerHandContainerViewController!.displayResult(currentPlayer.hands[playerHandContainerViewController!.playerHandIndex!].handState)
        for finishedHandsIndex in 0..<3 {
            if let handIndex = playerFinishedHandsVC[finishedHandsIndex].playerHandIndex {
                playerFinishedHandsVC[finishedHandsIndex].displayResult(currentPlayer.hands[handIndex].handState)
            }
        }
        if currentPlayer!.currentHandIndex == 0 {
            switch currentPlayer!.hands[0].handState{
            case .Won, .NaturalBlackjack:
                gameSound = .Won
            case .Lost, .Surrendered:
                gameSound = .Lost
            default:
                gameSound = .Tied
            }
        }
        AudioController.play(gameSound)
        setupButtons()
    }
    
    func zoomStatusLabel(message: String) {
        let label = statusLabel
        label.center = CGPointMake(view.center.x, statusLabel.center.y)
        label.text = message
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.hidden = false
        UIView.animateWithDuration(1.5, delay: 0.0, options: nil, animations: {
            label.transform = CGAffineTransformMakeScale(1.4, 2.0)
            }, completion: { _ in
                label.transform = CGAffineTransformIdentity
        })
    }

    
    func readyForNextAction() -> Bool {
      
        if let dealerVC = dealerHandContainerViewController {
            if dealerVC.busyNow() {
                println("hold on dealerAnimating")
                zoomStatusLabel("Hold On Please - Dealer busy")
                AudioController.play(.Beep)
                return false
            }
        }
        if let playerVC = playerHandContainerViewController {
            if playerVC.busyNow() {
                println("hold on playerAnimating")
                zoomStatusLabel("Hold On Please - busy")
                AudioController.play(.Beep)
                return false
            }
        }
        statusLabel.text = ""
        return true
    }
    
    func startObservingBankroll(player: Player) {
        let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        player.addObserver(self, forKeyPath: "bankRoll", options: options, context: &MyObservationContext)
    }
    
    func stopObservingBankroll(player: Player) {
        player.removeObserver(self, forKeyPath: "bankRoll", context: &MyObservationContext)
   
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch (keyPath, context) {
        case("bankRoll", &MyObservationContext):
            println("Bankroll changed: \(change)")
            bankrollUpdate()
            
        case(_, &MyObservationContext):
            assert(false, "unknown key path")
            
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    @IBAction func cardShoeLongPressed(sender: UILongPressGestureRecognizer) {
        println("Card shoe was long pressed")
        if sender.state == .Ended  && blackjackGame.gameState == .Deal {
            blackjackGame.getNewShoe()
        }
    }
    @IBAction func doubleTappedView(sender: UITapGestureRecognizer) {
        if sender.state == .Ended && blackjackGame.gameState == .Players {
            println("Double tapped the view")
            performHit()
        }
    }
    
    @IBAction func swipedTheViewUp(sender: UISwipeGestureRecognizer) {
        if sender.state == .Ended  && blackjackGame.gameState == .Deal  {
            println("swiped  the view UP")
            deal()
        }

    }
    
    @IBAction func swipedTheView(sender: UISwipeGestureRecognizer) {
        if sender.state == .Ended && blackjackGame.gameState == .Players {
            println("swiped  the view")
            performStand()
        }
    }
}

