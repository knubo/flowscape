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
    
    static var score:GameScore?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let score = HighScoreDetailsViewController.score!
        
        levelLabel.text = String(score.level)
        
        let lab:Labyrinth = Labyrinth(image:UIImage())
        
        let dim = HighScores.sharedInstance.getDimensions()
        

        DispatchQueue.global(qos: .background).async {

            lab.simulate(score: score, width: dim.x, height: dim.y)
            
            DispatchQueue.main.async {
                self.gameBoard.image = lab.imageView.image
                self.gameBoard.setNeedsDisplay()
            }
        }
      
    }
    
    
    //MARK: Actions
	
    @IBAction func playAgainAction(_ sender: Any) {
        Labyrinth.level = HighScoreDetailsViewController.score!.level
        
        performSegue(withIdentifier: "playSelectedGame", sender:self)
        
    }
  
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
  
}
