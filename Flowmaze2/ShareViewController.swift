//
//  ShareViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 18.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit

class ShareViewController: UIViewController {
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var tickLabel: UILabel!

    
    override func viewDidLayoutSubviews() {
        let str = HighScores.sharedInstance.getQRCode(level: HighScoreDetailsViewController.score!.level)
        let q = QRCode(str)
        
        levelLabel.text = "Level: "+String(HighScoreDetailsViewController.score!.level)
        tickLabel.text = "Tick: "+String(HighScoreDetailsViewController.score!.endTick)
        
        qrCodeImage.image = q?.image
        
        nameLabel.text = HighScores.sharedInstance.getMyName()
        
        logoImage.image = UIImage(named: "Flowmaze.png")!
    }

    //MARK: Actions
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true) {
        }
    }

    @IBAction func share(_ sender: Any) {
        
    }

}
