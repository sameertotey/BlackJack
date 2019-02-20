//
//  GameConfigurationControllerTableViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import GameKit

class GameConfigurationControllerTableViewController: UITableViewController, UITextFieldDelegate, GKGameCenterControllerDelegate {
    
    let gameConfiguration = GameConfiguration()

    @IBOutlet weak var numDecksLabel: UILabel!
    @IBOutlet weak var numDecksSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var redealThresholdLabel: UILabel!
    @IBOutlet weak var redealThresholdSlider: UISlider!
    
    @IBOutlet weak var blackjackPayoutMultiplierLabel: UILabel!
    @IBOutlet weak var blackjackPayoutMultiplierSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var splitsAllowedSwitch: UISwitch!
    @IBOutlet weak var canSplitAcesSwitch: UISwitch!
    @IBOutlet weak var onlyOneCardForSplitAcesSwitch: UISwitch!
    @IBOutlet weak var any10ValueCardSplitAllowedSwitch: UISwitch!
    
    @IBOutlet weak var maxHandsAfterSplitsLabel: UILabel!
    @IBOutlet weak var maxHandsAfterSplitsSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var doubleDownAllowedLabel: UILabel!
    @IBOutlet weak var doubleDownAllowedSwitch: UISwitch!
    @IBOutlet weak var doubleDownOnlyOn10and11Switch: UISwitch!
    @IBOutlet weak var doubleDownOnlyOn9and10and11Switch: UISwitch!
    
    @IBOutlet weak var insuranceAllowedSwitch: UISwitch!
    @IBOutlet weak var surrenderAllowedSwitch: UISwitch!
    @IBOutlet weak var checkHoleCardSwitch: UISwitch!
    @IBOutlet weak var dealerMustHitSoft17Switch: UISwitch!
    
    @IBOutlet weak var minimumBetAmountTextField: UITextField!
    @IBOutlet weak var maximumBetAmountTextField: UITextField!
    
    @IBOutlet weak var autoStandOnPlayer21Switch: UISwitch!
    @IBOutlet weak var autoWagerPreviousBetSwitch: UISwitch!
    @IBOutlet weak var enableSoundEffectsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        setupCurrentValues()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveFromConfiguration" {
            gameConfiguration.save()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Convinience helpers
    
    func setupCurrentValues() {
        numDecksLabel.text = "Number of Decks: \(gameConfiguration.numDecks)"
        switch Int(gameConfiguration.numDecks) {
        case 1:
            numDecksSegmentedControl.selectedSegmentIndex = 0
        case 2:
            numDecksSegmentedControl.selectedSegmentIndex = 1
        case 4:
            numDecksSegmentedControl.selectedSegmentIndex = 2
        case 6:
            numDecksSegmentedControl.selectedSegmentIndex = 3
        case 8:
            numDecksSegmentedControl.selectedSegmentIndex = 4
        default:
            print("Error: found number decks = \(gameConfiguration.numDecks)")
        }
        
        redealThresholdLabel.text = "Deck Penetration To: \(gameConfiguration.redealThreshold)"
        redealThresholdSlider.value = Float(gameConfiguration.redealThreshold)
        blackjackPayoutMultiplierLabel.text = "Blackjack Payout Multiple: \(gameConfiguration.multipleForPlayerBlackjack)"
        switch gameConfiguration.multipleForPlayerBlackjack {
        case 1.0:
            blackjackPayoutMultiplierSegmentedControl.selectedSegmentIndex = 2
        case 1.2:
            blackjackPayoutMultiplierSegmentedControl.selectedSegmentIndex = 1
        case 1.5:
            blackjackPayoutMultiplierSegmentedControl.selectedSegmentIndex = 0
        default:
            print("Error: found Blackjack payout = \(gameConfiguration.multipleForPlayerBlackjack)")
        }

        splitsAllowedSwitch.isOn = gameConfiguration.splitsAllowed
        canSplitAcesSwitch.isOn = gameConfiguration.canSplitAces
        onlyOneCardForSplitAcesSwitch.isOn = gameConfiguration.onlyOneCardOnSplitAces
        any10ValueCardSplitAllowedSwitch.isOn = gameConfiguration.canSplitAny10Cards
        maxHandsAfterSplitsLabel.text = "Max Hands After Splits: \(gameConfiguration.maxHandsWithSplits)"
        switch gameConfiguration.maxHandsWithSplits {
        case 2:
            maxHandsAfterSplitsSegmentedControl.selectedSegmentIndex = 0
        case 3:
            maxHandsAfterSplitsSegmentedControl.selectedSegmentIndex = 1
        case 4:
            maxHandsAfterSplitsSegmentedControl.selectedSegmentIndex = 2
        default:
            print("Error: found max hands after splits = \(gameConfiguration.maxHandsWithSplits)")
        }
        doubleDownAllowedSwitch.isOn = gameConfiguration.doublingDownAllowed
        doubleDownOnlyOn10and11Switch.isOn = gameConfiguration.doublingDownAllowedOn10and11Only
        doubleDownOnlyOn9and10and11Switch.isOn = gameConfiguration.doublingDownAllowedOn9and10and11Only
        insuranceAllowedSwitch.isOn = gameConfiguration.insuranceAllowed
        surrenderAllowedSwitch.isOn = gameConfiguration.surrenderAllowed
        checkHoleCardSwitch.isOn = gameConfiguration.checkHoleCardForDealerBlackJack
        dealerMustHitSoft17Switch.isOn = gameConfiguration.dealerMustHitSoft17
        minimumBetAmountTextField.text = "\(gameConfiguration.minimumBet)"
        maximumBetAmountTextField.text = "\(gameConfiguration.maximumBet)"
        autoStandOnPlayer21Switch.isOn = gameConfiguration.autoStandOnPlayer21
        autoWagerPreviousBetSwitch.isOn = gameConfiguration.autoWagerPreviousBet
        enableSoundEffectsSwitch.isOn = gameConfiguration.enableSoundEffects
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return 17
        case 1:
            return 3
        case 2:
            return 3
        default:
            return 0
        }
    }
    
    @IBAction func numDecksSegmentedControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gameConfiguration.numDecks = 1
        case 1:
            gameConfiguration.numDecks = 2
        case 2:
            gameConfiguration.numDecks = 4
        case 3:
            gameConfiguration.numDecks = 6
        case 4:
            gameConfiguration.numDecks = 8
        default:
            print("Error index received for numDecks")
        }
        numDecksLabel.text = "Number of Decks: \(gameConfiguration.numDecks)"
    }
    
    @IBAction func blackjackPayoutMultiplierSegmentedControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gameConfiguration.multipleForPlayerBlackjack = 1.5
        case 1:
            gameConfiguration.multipleForPlayerBlackjack = 1.2
        case 2:
            gameConfiguration.multipleForPlayerBlackjack = 1.0
        default:
            print("Error index received for blackjack payout multiplier")
        }
        blackjackPayoutMultiplierLabel.text = "Blackjack Payout Multiple: \(gameConfiguration.multipleForPlayerBlackjack)"
    }
    
    @IBAction func redealThresholdSliderValueChanged(sender: UISlider) {
        redealThresholdLabel.text = "Redeal Threshold: \(Int(sender.value))"
        gameConfiguration.redealThreshold = Int(sender.value)
    }
    
    
    @IBAction func maxHandsAfterSplitsSegmentedControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            gameConfiguration.maxHandsWithSplits = 2
        case 1:
            gameConfiguration.maxHandsWithSplits = 3
        case 2:
            gameConfiguration.maxHandsWithSplits = 4
        default:
            print("Error index received for max hands after split")
        }
        maxHandsAfterSplitsLabel.text = "Max Hands After Splits: \(gameConfiguration.maxHandsWithSplits)"
    }
    
    @IBAction func SwitchValueChanged(sender: UISwitch) {
        switch sender {
        case doubleDownAllowedSwitch:
            gameConfiguration.doublingDownAllowed = sender.isOn
        case splitsAllowedSwitch:
            gameConfiguration.splitsAllowed = sender.isOn
        case insuranceAllowedSwitch:
            gameConfiguration.insuranceAllowed = sender.isOn
        case surrenderAllowedSwitch:
            gameConfiguration.surrenderAllowed = sender.isOn
        case checkHoleCardSwitch:
            gameConfiguration.checkHoleCardForDealerBlackJack = sender.isOn
        case dealerMustHitSoft17Switch:
            gameConfiguration.dealerMustHitSoft17 = sender.isOn
        case canSplitAcesSwitch:
            gameConfiguration.canSplitAces = sender.isOn
        case onlyOneCardForSplitAcesSwitch:
            gameConfiguration.onlyOneCardOnSplitAces = sender.isOn
        case any10ValueCardSplitAllowedSwitch:
            gameConfiguration.canSplitAny10Cards = sender.isOn
        case doubleDownOnlyOn10and11Switch:
            gameConfiguration.doublingDownAllowedOn10and11Only = sender.isOn
        case doubleDownOnlyOn9and10and11Switch:
            gameConfiguration.doublingDownAllowedOn9and10and11Only = sender.isOn
        case autoStandOnPlayer21Switch:
            gameConfiguration.autoStandOnPlayer21 = sender.isOn
        case autoWagerPreviousBetSwitch:
            gameConfiguration.autoWagerPreviousBet = sender.isOn
        case enableSoundEffectsSwitch:
            gameConfiguration.enableSoundEffects = sender.isOn
        default: break
        }
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case minimumBetAmountTextField:
            if let number = NumberFormatter().number(from: textField.text!) {
                gameConfiguration.minimumBet = number.doubleValue
                if gameConfiguration.minimumBet > gameConfiguration.maximumBet {
                    gameConfiguration.minimumBet = gameConfiguration.maximumBet
                }
            }
        case maximumBetAmountTextField:
            if let number = NumberFormatter().number(from: textField.text!) {
                gameConfiguration.maximumBet = number.doubleValue
                if gameConfiguration.maximumBet < gameConfiguration.minimumBet {
                    gameConfiguration.maximumBet = gameConfiguration.minimumBet
                }
            }

        default: break

        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //
        //        println("Did select row \(indexPath.section) \(indexPath.row)")
        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            displayGameCenterVC(leaderBoardID: "Blackjack")
        case (2, 1):
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationMessages.resetPlayerScore), object: nil)
        case (2, 2):
            GKAchievement.resetAchievements(completionHandler: { error in
                
            })

        default:
            print("Do nothing for now")
        }
    }
    
    func displayGameCenterVC(leaderBoardID:String) {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        gameCenterViewController.leaderboardIdentifier = leaderBoardID
        present(gameCenterViewController, animated: true, completion: nil)
    }

    // MARK: - GKGameCenterDelegate
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
//        println("Game Center View Controller Did Finish")
        dismiss(animated: true, completion: nil)
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
}
