//
//  EnemyBasis.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 01.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit
import GameKit


class EnemyBasis {
    let parent:Labyrinth
    let rs:GKMersenneTwisterRandomSource
    let allDirections:[Point] = [Point(x:1, y:0), Point(x:-1, y:0), Point(x:0,y:-1), Point(x:0,y:1)]
    let allSurrounding:[Point] = [Point(x:1, y:0), Point(x:1, y:1), Point(x:1, y:-1), Point(x:0, y:1), Point(x:0, y:-1), Point(x:-1,y:-1), Point(x:-1,y:1), Point(x:-1,y:0)]

    init(parent: Labyrinth, rs:GKMersenneTwisterRandomSource) {
        self.parent = parent
        self.rs = rs
    }
    
    func tick(context:CGContext) {
        
    }
   
    func randomWallPoint() -> Point {
        let x = rs.nextInt(upperBound:parent.mazeColSize-2)
        let y = rs.nextInt(upperBound:parent.mazeRowSize-4) + 2
        
        if(parent.board[y][x]) {
            return randomStartPoint()
        }
        
        return Point(x:x, y:y)
    }
    
    func randomStartPoint() -> Point {
        let x = rs.nextInt(upperBound:parent.mazeColSize-2)
        let y = rs.nextInt(upperBound:parent.mazeRowSize-4) + 2
        
        if(!parent.board[y][x]) {
            return randomStartPoint()
        }
        
        return Point(x:x, y:y)
    }
    
    func outOfBounds(y:Int, x:Int) -> Bool {
        return parent.outOfBounds(y:y, x:x)
    }
    
    func outOfBoundsCells(y:Int, x:Int) -> Bool {
        return parent.outOfBoundsCells(y:y, x:x)
    }
}
