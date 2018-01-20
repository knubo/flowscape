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
    
    override func viewDidLayoutSubviews() {
        let str = HighScores.sharedInstance.getQRCode(level: HighScoreDetailsViewController.score!.level)
        let q = QRCode(str)
        
        qrCodeImage.image = q?.image
        
        logoImage.image = UIImage(named: "Flowmaze.png")!
    }

}
