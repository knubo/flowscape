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
    
    static var level:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        levelLabel.text = String(HighScoreDetailsViewController.level)
    }
    
    
    //MARK: Actions
	
    @IBAction func playAgainAction(_ sender: Any) {
       Labyrinth.level = HighScoreDetailsViewController.level
        
        performSegue(withIdentifier: "playSelectedGame", sender:self)
        
    }
  
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
}
