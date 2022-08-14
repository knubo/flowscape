//
//  HighScoreViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 01.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit

class HighScoreViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
 
    var items:[GameScore] = []
    
    var currentLevel:GameScore? = nil
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items = HighScores.sharedInstance.scores()
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let score = self.items[indexPath.item]
        cell.levelLabel.text = String(score.level)
        cell.scoreLabel.text = String(score.endTick)
        cell.levelLabel.textColor = UIColor.black
        cell.scoreLabel.textColor = UIColor.black
        
        cell.backgroundColor = score.myScore ?
            UIColor(red:1.00, green:1.00, blue:0.60, alpha:1.0):
            UIColor(red:1.00, green:0.5, blue:0, alpha:1.0)
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        let score = self.items[indexPath.item]

        currentLevel = HighScores.sharedInstance.getFullScore(l: score.level, who:score.who)
        print("You selected cell #\(indexPath.item)!")
        
        HighScoreDetailsViewController.score = currentLevel
        performSegue(withIdentifier: "showDetails", sender:self)
    }
    
}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
}
