//
//  HighScoreDetailsViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 06.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit

class HighScoreDetailsViewController: UIViewController {
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var gameBoard: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    static var score:GameScore?;
    var timer:Timer? = nil

    var lab:Labyrinth? = nil
    var actionIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let score = HighScoreDetailsViewController.score!
        
        levelLabel.text = String(score.level) + (score.myScore ? "" : " - "+score.who)
        
        let lab:Labyrinth = Labyrinth(image:UIImage())
        
        let dim = HighScores.sharedInstance.getDimensions()
        
        shareButton.isHidden = !score.myScore
        
        
        DispatchQueue.global(qos: .background).async {

            lab.simulateFast(score: score, width: dim.x, height: dim.y)
            
            DispatchQueue.main.async {
                self.gameBoard.image = lab.imageView.image
                self.gameBoard.setNeedsDisplay()
            }
        }
      
    }
    
    
    //MARK: Actions
	
    @IBAction func playAgainAction(_ sender: Any) {
        Labyrinth.level = HighScoreDetailsViewController.score!.level
        
        timer?.invalidate()

        performSegue(withIdentifier: "playSelectedGame", sender:self)
        
    }
    
    @IBAction func shareAction(_ sender: Any) {
        performSegue(withIdentifier: "share", sender:self)
    }
    
    @IBAction func simulateAction(_ sender: Any) {
        Labyrinth.level = HighScoreDetailsViewController.score!.level
        let score = HighScoreDetailsViewController.score!
        actionIndex = 0
        
        lab = Labyrinth(image:UIImage())
        
        let dim = HighScores.sharedInstance.getDimensions()
        
        lab!.simulateSlow(score: score, width: dim.x, height: dim.y)
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: lab!.timeBetweenDraw, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
  
    @objc func updateTimer() {
        lab!.tick = lab!.tick + 1
        
        let score = HighScoreDetailsViewController.score!

        if(lab!.tick > score.endTick) {
            timer?.invalidate()
            return
        }
        
        while(score.actions.count > actionIndex && score.actions[actionIndex].tick == lab!.tick) {
            lab!.toggleCellValueAt(score.actions[actionIndex].y, score.actions[actionIndex].x)
            actionIndex = actionIndex + 1
        }
        
        lab!.gameLoop()
        self.gameBoard.image = lab!.imageView.image
        self.gameBoard.setNeedsDisplay()
    }
    
    @IBAction func backAction(_ sender: Any) {
        timer?.invalidate()

        dismiss(animated: true) {
        }
    }
    
  
}
