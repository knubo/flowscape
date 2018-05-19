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
    
    let snake = "11111222223000000000000000000001112221131145661"
    let flow =  "00000000000111112222300000000001001001111100000"
    let burn =  "00000000000000000000011111000000100100000000000"
    let fill =  "00000000000000000000000000111110010010101100001"
    let nice =  "00010001000001000000000100000000000000000100010"
    let laser = "00000000000000000000000000000000000000000000001"
    
 
    
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
