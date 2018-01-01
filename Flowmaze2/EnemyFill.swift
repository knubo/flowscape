//
//  EnemyBurn.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 01.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class EnemyFill:EnemyBasis {
    
    var fillPoints:[Point] = []
    
    var tickCount = 0
    
    override init(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        super.init(parent: parent, rs: rs)
        
        fillPoints.append(randomStartPoint())
    }
    
    override func tick(context:CGContext) {
        
        context.setFillColor(rs.nextBool() ? UIColor.gray.cgColor : UIColor.darkGray.cgColor)
        for p in fillPoints {
            context.fill(parent.boxAt(p: p))
        }
        
        context.strokePath()
        
        if(tickCount < 80) {
            tickCount = tickCount + 1
            return
        }
        
        tickCount = 0;
        
        context.setFillColor(parent.colorWall)
        for p in fillPoints {
            context.fill(parent.boxAt(p: p))
            parent.board[p.y][p.x] = false
        }
        context.strokePath()
        
        var newBurnPoints:[Point] = []
        
        for p in fillPoints {
            if(newBurnPoints.count > 15) {
                break
            }
            
            for d in allDirections {
                let nextY = p.y+d.y
                let nextX = p.x+d.x
                
                if(outOfBoundsCells(y: nextY, x:nextX) || !parent.board[nextY][nextX]) {
                    continue
                }
                
                
                newBurnPoints.append(Point(x: nextX, y: nextY))
            }
        }
        fillPoints = newBurnPoints
        
    }
    
}

