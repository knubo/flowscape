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
import GameKit

class HighScores {
    static let sharedInstance = HighScores()
    
    func postScore(score:GameScore, rs:GKMersenneTwisterRandomSource) -> Bool {
        let defaults = UserDefaults.standard
        
        defaults.set(score.boardSize!.x, forKey:"board_size_x")
        defaults.set(score.boardSize!.y, forKey:"board_size_y")
        
        let maxLevel =  defaults.integer(forKey:"max_successful_level")
        if(score.level > maxLevel) {
            defaults.set(score.level, forKey:"max_successful_level")
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
      
        var s:String = ""
        for _ in 1...40 {
            s = s + String(rs.nextInt(upperBound:9))
        }
        
        defaults.set(s, forKey: String(score.level)+"checksum_me")
        
        return true
    }
    
    func getLastCompletedLevel() -> Int {
        let defaults = UserDefaults.standard

        return defaults.integer(forKey:"max_successful_level")
    }
    
    func setDimensions(width:Int, height:Int) {
        let defaults = UserDefaults.standard

        defaults.set(width, forKey:"pixel_width")
        defaults.set(height, forKey:"pixel_height")
    }
    
    func getDimensions() -> Point {
        let defaults = UserDefaults.standard

        return Point(x:defaults.integer(forKey:"pixel_width"), y:defaults.integer(forKey:"pixel_height"))
    }
    
    func getMyName() -> String {
        let defaults = UserDefaults.standard
        
        let name = defaults.string(forKey: "share_name")
        
        if(name != nil) {
            return name!
        }
        
        return "Player 1"
    }
    
    
    func getQRCode(level:Int) -> String {
        let defaults = UserDefaults.standard
        
        let score = getFullScore(l:level)
        
        let jsonObject: [String: String] = [
            "pw": defaults.string(forKey:"pixel_width")!,
            "ph":defaults.string(forKey:"pixel_height")!,
            "bx":defaults.string(forKey:"board_size_x")!,
            "by":defaults.string(forKey:"board_size_y")!,
            "tk":String(score.endTick),
            "ll":String(score.level),
            "wn":score.when!.description,
            "ms":score.describeActions(),
            "cs": defaults.string(forKey:String(level)+"checksum_me")!
            ]
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(jsonObject)
            return String(data: data, encoding: .utf8)!
        } catch {
            return ""
        }
    }
    
    func scores() -> [GameScore] {
        let defaults = UserDefaults.standard

        let levels = defaults.stringArray(forKey:"levels") ?? [String]()

        let boardSize:Point = Point(x:defaults.integer(forKey:"board_size_x"),y:defaults.integer(forKey:"board_size_y"))
        
        var scores:[GameScore] = []
        
        for l in levels {
            let tick = defaults.integer(forKey: l + "_tick_me")

            scores.append(GameScore(actions:[], endTick:tick, level:Int(l)!, boardSize:boardSize))
        }
        
        return scores
    }
    
    func getFullScore(l:Int) -> GameScore {
        let level = String(l)
        let defaults = UserDefaults.standard

        let tick = defaults.integer(forKey: level + "_tick_me")
        let when:Date = defaults.object(forKey: level+"_when_me") as! Date
        let moves = defaults.string(forKey: level+"moves_me")
        
        let boardSize:Point = Point(x:defaults.integer(forKey:"board_size_x"),y:defaults.integer(forKey:"board_size_y"))

        let elements = moves!.split(separator:",")
        
        
        var actions:[GameAction] = []
        
        
        var i:Int = 0
        while i < elements.count {
            let x = String(elements[i])
            let y = String(elements[i+1])
            let tick = String(elements[i+2])
            let cellValue = String(elements[i+3]) == "1" ? true : false
            
            actions.append(GameAction(x:Int(x)!,
                                      y:Int(y)!,
                                      tick:Int(tick)!,
                                      cellValue:cellValue))
            i = i + 4
        }
        
        
        return GameScore(actions: actions, endTick: tick, level: l, when:when, boardSize:boardSize)
    }
    
}

struct GameAction {
    var x = 0, y = 0, tick = 0
    var cellValue = false
    
    func info() -> String {
        return String(format:"%d,%d,%d,%d", x, y, tick, cellValue ? 1 : 0)
    }
}

struct GameScore {
    var actions:[GameAction]
    var endTick = 0
    var level = 0
    var when:Date? = nil
    var boardSize:Point? = nil
    
    init(actions:[GameAction], endTick:Int, level:Int, boardSize:Point) {
        self.actions = actions
        self.endTick = endTick
        self.level = level
        self.boardSize = boardSize
    }
    
    init(actions:[GameAction], endTick:Int, level:Int, when:Date, boardSize:Point) {
        self.actions = actions
        self.endTick = endTick
        self.level = level
        self.when = when
        self.boardSize = boardSize
    }
    
    func describeActions() -> String {
        return actions.map {g in g.info()}.joined(separator:",")
    }
}
