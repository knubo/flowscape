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
    
    let snake = "11111222223000000000000000000001112221121456"
    let flow =  "00000000000111112222300000000001001001111000"
    let burn =  "00000000000000000000011111000000100101011000"
    let fill =  "00000000000000000000000000111110010010101000"
    
    
    func allocateByRandom(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        //TODO!
        
        
    }
    func addBadThings(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        let level = parent.level;
        
        if(level > snake.count) {
            allocateByRandom(parent:parent, rs:rs)
            return
        }
        
        var count = valueAtLocation(str:snake, pos:level)
        
        while(count > 0) {
            count = count - 1
            parent.badThings.append(EnemySnake(parent:parent, rs:rs))
        }
        
        count = valueAtLocation(str: flow, pos: level)
        
        while(count > 0) {
            count = count - 1
            parent.badThings.append(EnemyFlow(parent:parent, rs:rs))
        }
        
        count = valueAtLocation(str: burn, pos: level)
        
        while(count > 0) {
            count = count - 1
            parent.badThings.append(EnemyBurn(parent:parent, rs:rs))
        }
        
        count = valueAtLocation(str: fill, pos:level)
        while(count > 0) {
            count = count - 1
            parent.badThings.append(EnemyFill(parent:parent, rs:rs))
        }
        
        
        
    }
    
    func valueAtLocation(str:String, pos:Int) -> Int {
        let startIndex = str.index(str.startIndex, offsetBy: pos)
        let endIndex = str.index(str.startIndex, offsetBy: pos)
        let v = String(str[startIndex...endIndex])
        
        return Int(v)!
    }
    
    //    badThings.append(EnemyFlow(parent:self, rs:rs))
    //      badThings.append(EnemyFlow(parent:self, rs:rs))
    //     badThings.append(EnemySnake(parent:self, rs:rs))
    //    badThings.append(EnemySnake(parent:self, rs:rs))
    
    //    badThings.append(EnemyBurn(parent:self, rs:rs))
    //    badThings.append(EnemyFill(parent:self, rs:rs))
    
}
