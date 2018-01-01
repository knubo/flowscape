//
//  EnemySnake.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 01.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class EnemySnake:EnemyBasis {
    
    var tail:[Point] = []
    var direction:Point = Point(x:1, y:0)
    
    var tickWait = 10;
    
    let allDirections:[Point] = [Point(x:1, y:0), Point(x:-1, y:0), Point(x:0,y:-1), Point(x:0,y:1)]
    
    override init(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        super.init(parent: parent, rs: rs)
        
        let startPoint = randomStartPoint()
        
        tail.append(startPoint)
        tail.append(startPoint)
        tail.append(startPoint)
    }
    
    override func tick(context:CGContext) {
        tickWait = tickWait - 1;
        
        if(tickWait > 0) {
            return
        }
        tickWait = 10
    
        let toClear = tail.removeFirst()
        
        context.setFillColor(UIColor.white.cgColor)

        context.fill(parent.boxAt(toClear.x, toClear.y))
        
        tail.append(moveFrom(point:tail.last!))

        let tailCol = UIColor(red:CGFloat(32),green:CGFloat(178),blue:CGFloat(170), alpha:CGFloat(0)).cgColor
        
        for p in tail {
            context.setFillColor(p == tail.last ? UIColor.cyan.cgColor : tailCol)
            context.fill(parent.boxAt(p:p))
            
        }
        
        context.strokePath()
    }
    
    fileprivate func canMoveTo(_ nextPoint: Point) -> Bool {
        return nextPoint.x < parent.mazeColSize && nextPoint.x >= 0 &&
            nextPoint.y < parent.mazeRowSize && nextPoint.y >= 0 &&
            parent.board[nextPoint.y][nextPoint.x]
    }
    
    func moveFrom(point :Point) -> Point {

        let reverse = direction.inverse()
        var check = Array(allDirections.filter { $0 != reverse })
        
        while check.count > 0 {
            direction = check[rs.nextInt(upperBound:check.count)]
            
            check = check.filter {$0 != direction }

            let nextPoint = point.move(direction:direction)
        
            if(canMoveTo(nextPoint)) {
                return nextPoint
            }
        }
        
        /* No direction, let try moving backwards */
        let nextPoint = point.move(direction:reverse)
        
        if(canMoveTo(nextPoint)) {
            direction = reverse
            return nextPoint
        }
        
        /* Still no direction, just let it stay and wait until next time */
        
        return point
        
        
    }
    
}


class EnemyBasis {
    let parent:Labyrinth
    let rs:GKMersenneTwisterRandomSource
    
    init(parent: Labyrinth, rs:GKMersenneTwisterRandomSource) {
        self.parent = parent
        self.rs = rs
    }
    
    func tick(context:CGContext) {
        
    }
    
    func randomStartPoint() -> Point {
        let x = rs.nextInt(upperBound:parent.mazeColSize-2)
        let y = rs.nextInt(upperBound:parent.mazeRowSize-4) + 2
        
        if(!parent.board[y][x]) {
            return randomStartPoint()
        }
        
        return Point(x:x, y:y)
    }
}
