//
//  GameConfigurationControllerTableViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class GameConfigurationControllerTableViewController: UITableViewController, UITextFieldDelegate {
    
    let gameConfiguration = GameConfiguration()

    @IBOutlet weak var numDecksLabel: UILabel!
    @IBOutlet weak var numDecksStepper: UIStepper!
    
    @IBOutlet weak var redealThresholdLabel: UILabel!
    @IBOutlet weak var redealThresholdSlider: UISlider!
    
    @IBOutlet weak var blackjackPayoutMultiplierLabel: UILabel!
    @IBOutlet weak var blackjackPayoutMultiplierTextField: UITextField!
    
    @IBOutlet weak var splitsAllowedLabel: UILabel!
    @IBOutlet weak var splitsAllowedSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        setupCurrentValues()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
        numDecksStepper.value = Double(gameConfiguration.numDecks)
        redealThresholdLabel.text = "Redeal Threhold: \(gameConfiguration.redealThreshold)"
        redealThresholdSlider.value = Float(gameConfiguration.redealThreshold)
        blackjackPayoutMultiplierTextField.text = "\(gameConfiguration.multipleForPlayerBlackjack)"
        splitsAllowedSwitch.on = gameConfiguration.splitsAllowed
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 8
    }

    @IBAction func numDecksStepperValueChanged(sender: UIStepper) {
        numDecksLabel.text = "Number of Decks: \(Int(sender.value))"
        gameConfiguration.numDecks = Int(sender.value)
    }
    
    @IBAction func redealThresholdSliderValueChanged(sender: UISlider) {
        redealThresholdLabel.text = "Redeal Threshold: \(Int(sender.value))"
        gameConfiguration.redealThreshold = Int(sender.value)
    }
    
    @IBAction func splitsAllowedSwitchValueChanged(sender: UISwitch) {
        if sender === splitsAllowedSwitch {
            gameConfiguration.splitsAllowed = sender.on
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let number = NSNumberFormatter().numberFromString(blackjackPayoutMultiplierTextField.text) {
            gameConfiguration.multipleForPlayerBlackjack = number.doubleValue
        }
        
        return true
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
