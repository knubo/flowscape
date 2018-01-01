//
//  EnemyFlow.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 01.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class EnemyFlow:EnemyBasis {
    var drawPoints:Set = Set<CGPoint>()

    var wallColorArray:[CUnsignedChar] = [];
    var fillColorArray:[CUnsignedChar] = [];
    var limitColorArray:[CUnsignedChar] = [];
    
    let fillColor = UIColor.red.cgColor
    
    

    override init(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        super.init(parent: parent, rs: rs)
        
        let startPoint = randomStartPoint()
        
        drawPoints.insert( CGPoint(x:parent.marginLeft + parent.boxSize * startPoint.x + parent.boxSize / 2, y:parent.marginTop + parent.boxSize * startPoint.y + parent.boxSize / 2) );

        wallColorArray = parent.colorWall.getColorArray()
        fillColorArray = fillColor.getColorArray()
        limitColorArray = UIColor.black.cgColor.getColorArray()
        
    }
    override func tick(context:CGContext) {

        let checkCoords = [(1,0),(0,1),(-1,0),(0,-1)]
        
        var newPoints:Set = Set<CGPoint>();
        
        context.setFillColor(fillColor)

        findNewPoints(context, checkCoords, &newPoints)
        
        context.strokePath()
        
        drawPoints = newPoints
        
    }
    
    fileprivate func findNewPoints(_ context: CGContext?, _ checkCoords: [(Int, Int)], _ newPoints: inout Set<CGPoint>) {
        
        for point in drawPoints {
            let x = Int(point.x)
            let y = Int(point.y)
            
            context?.fill(CGRect(x: x, y: y, width: 1, height: 1 ))
            
            for (p1,p2) in checkCoords {
                
                if(outOfBounds(y: y+p1, x:x+p2)) {
                    continue
                }
                
                let c = parent.imageView.image!.getPixelColor(y: y + p1, x: x + p2)
                
                let isWallColor = c[0] == wallColorArray[0] && c[1] == wallColorArray[1] && c[2] == wallColorArray[2]
                let isFill = c[0] == fillColorArray[0] && c[1] == fillColorArray[1] && c[2] == fillColorArray[2]

                if(!isFill && !isWallColor) {
                    newPoints.insert ( CGPoint(x:x+p2, y:y+p1) )
                }
            }
        }
    }
}
