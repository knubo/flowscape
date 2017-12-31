//
//  HighScores.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 30.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//
// "levels" : [1,2,3,4,5,6,...]
// "level" : ["me"]
// level+"_moves_me" -> ["x:10,y:10,tick:10,cell:true", "x:15,y:40,tick:2000,cell:false"]
// level+"_tick_me" -> tick
// level+"_when_me" -> Date
//
// Store lowest tick.

import Foundation

class HighScores {
    static let sharedInstance = HighScores()
    
    func postScore(score:GameScore) -> Bool {
        let defaults = UserDefaults.standard
        
        let maxLevel =  defaults.integer(forKey:"max_successful_level")
        if(score.level > maxLevel) {
            defaults.set(score.level, forKey:"last_successsful_level")
        }
        
        var levels = defaults.stringArray(forKey:"levels") ?? [String]()
        
        if(!levels.contains(String(score.level))) {
            levels.append(String(score.level))
            defaults.set(levels, forKey:"levels")
        }
        
        var who = defaults.stringArray(forKey:String(score.level)) ?? [String]()
        if(!who.contains("me")) {
            who.append("me")
            defaults.set(who, forKey:String(score.level))
        }
        
        let tick = defaults.integer(forKey: String(score.level) + "_tick_me")
        
        if(tick != 0 && tick < score.endTick) {
            return false
        }
        
        defaults.set(score.endTick, forKey: String(score.level) + "_tick_me")
        defaults.set(Date(), forKey:String(score.level)+"_when_me")
        defaults.set(score.describeActions(), forKey:String(score.level)+"moves_me")

        
      
        return true
    }
    
    func getLastCompletedLevel() -> Int {
        let defaults = UserDefaults.standard

        return defaults.integer(forKey:"max_successful_level")
    }
    
}

struct GameAction {
    var x = 0, y = 0, tick = 0
    var cellValue = false
    
    func info() -> String {
        return String(format:"x:%d,y:%d,t:%t,v:%d", x, y, tick, cellValue ? 1 : 0)
    }
}

struct GameScore {
    var actions:[GameAction]
    var endTick = 0
    var level = 0
    
    func describeActions() -> String {
        return actions.map {g in g.info()}.joined(separator:",")
    }
}
