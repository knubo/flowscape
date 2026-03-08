//
//  MenuViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 28.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
      
    }
    
   
     //MARK: Actions
    @IBAction func playLatestGame(_ sender: Any) {
        Labyrinth.level = HighScores.sharedInstance.getLastCompletedLevel() + 1
        
        performSegue(withIdentifier: "playHighestLevel", sender:self)

        
    }
}
