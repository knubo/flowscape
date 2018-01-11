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
    
    let snake = "1111122222300000000000000000000111222112114566"
    let flow =  "0000000000011111222230000000000100100111110000"
    let burn =  "0000000000000000000001111100000010010101110000"
    let fill =  "0000000000000000000000000011111001001010110000"
    let nice =  "0001000100000100000000010000000000000000010001"
    
    
    func allocateByRandom(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        //TODO!
        
        
    }
    func addBadThings(parent:Labyrinth, rs:GKMersenneTwisterRandomSource) {
        let level = Labyrinth.level - 10;
        
        /* First 10 levels are "boring" */
        if(level < 0) {
            return
        }
        
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
        
        count = valueAtLocation(str: nice, pos:level)
        while(count > 0) {
            count = count - 1
            parent.badThings.append(NiceSnake(parent:parent, rs:rs))
        }
        
        
    }
    
    func valueAtLocation(str:String, pos:Int) -> Int {
        let startIndex = str.index(str.startIndex, offsetBy: pos)
        let endIndex = str.index(str.startIndex, offsetBy: pos)
        let v = String(str[startIndex...endIndex])
        
        return Int(v)!
    }
    
   
    
}
