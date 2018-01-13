//
//  EnemyLaser.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 11.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//


import Foundation
import UIKit
import GameKit

class EnemyLaser:EnemyBasis {
    
    var tick:Int = -(9 * 5);
    
    override init(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        super.init(parent: parent, rs: rs)
        
    }

    override func tick(context:CGContext) {
        tick = tick + 1;
        
        if(tick < 0) {
            return
        }
        
        context.setFillColor(UIColor.purple.cgColor)

        context.fill(CGRect(x:parent.marginLeft, y: parent.marginTop+tick, width:Int(parent.width) - parent.marginLeft, height:1))
        
        context.strokePath()

    }
    
}

