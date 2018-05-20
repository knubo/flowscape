//
//  LevelInfo.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 02.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class LevelInfo {
    static let sharedInstance = LevelInfo()
    
    let snake = "111112222230000000000000000000011122211311456610"
    let flow =  "000000000001111122223000000000010010011111000000"
    let burn =  "000000000000000000000111110000001001000000000000"
    let fill =  "000000000000000000000000001111100100101011000010"
    let nice =  "000100010000010000000001000000000000000001000102"
    let laser = "000000000000000000000000000000000000000000000011"
    
 
    
    func createSnake(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) -> EnemyBasis {
        return EnemySnake(parent:parent, rs:rs)
    }
    func createLaser(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) -> EnemyBasis {
        return EnemyLaser(parent:parent, rs:rs)
    }
    func createFlow(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) -> EnemyBasis {
        return EnemyFlow(parent:parent, rs:rs)
    }
    func createBurn(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) -> EnemyBasis {
        return EnemyBurn(parent:parent, rs:rs)
    }
    func createFill(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) -> EnemyBasis {
        return EnemyFill(parent:parent, rs:rs)
    }
    func createNiceSnake(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) -> EnemyBasis {
        return NiceSnake(parent:parent, rs:rs)
    }
    
    func addBadThings(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        var level = Labyrinth.level - 10;
        
        /* First 10 levels are "boring" */
        if(level < 0) {
            return
        }
        
        if(level > snake.count) {
            let minSnakeCount = level / snake.count

            for _ in 0..<minSnakeCount {
                parent.badThings.append(createSnake(parent:parent, rs:rs))
            }
         }
        
        level = level % snake.count
        
        let things:[(String,((Labyrinth, GKMersenneTwisterRandomSource)->EnemyBasis))] =
            [(snake,createSnake), (laser, createLaser), (flow, createFlow), (burn, createBurn), (fill, createFill),
             (nice, createNiceSnake)]
        
        
        for (str, c) in things {
            var count = valueAtLocation(str:str, pos:level)
            while(count > 0) {
                count = count - 1
                parent.badThings.append(c(parent, rs))
            }
        }
    
        
        
    }
    
    func valueAtLocation(str:String, pos:Int) -> Int {
        let startIndex = str.index(str.startIndex, offsetBy: pos)
        let endIndex = str.index(str.startIndex, offsetBy: pos)
        let v = String(str[startIndex...endIndex])
        
        return Int(v)!
    }
    
   
    
}
