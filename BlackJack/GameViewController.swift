//
//  ViewController.swift
//  BlackJack
//
//  Created by Sameer Totey on 2/2/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    @IBOutlet weak var playingCardView: PlayingCardView!
    
    let playingCardShoe = BlackjackCardShoe(numDecks: 2)

    
    @IBAction func cardTapped(sender: UITapGestureRecognizer) {

        if playingCardView.faceUp {
            playingCardView.faceUp = false
        } else {
            playingCardView.faceUp = true
            playingCardView.card = playingCardShoe.drawCardFromTop()
            println(playingCardView.card)
        }
    }
    
}

